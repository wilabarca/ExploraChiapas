import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import '../error/exceptions.dart';
import '../navigation/app_navigator.dart';
import '../storage/secure_session_storage.dart';
import 'dart:io';
import '../utils/app_constants.dart';
import 'gateway_certificate_pinning.dart';

@lazySingleton
class ApiClient {
  late final Dio _dio;
  final SecureSessionStorage _secureStorage;

  static const String _baseUrl = AppConstants.baseUrl;

  ApiClient(this._secureStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.httpClientAdapter = GatewayCertificatePinning.createAdapter();

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          if (kDebugMode) {
            debugPrint('${options.method} ${options.path}');
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            final gateway = response.headers.value('x-gateway');
            if (gateway != null) {
              debugPrint('X-Gateway: $gateway');
            }
            debugPrint(
              '${response.statusCode} ${response.requestOptions.path}',
            );
          }
          handler.next(response);
        },
        onError: (error, handler) async {
          if (kDebugMode) {
            debugPrint(
              'Error ${error.response?.statusCode} '
              '${error.requestOptions.path}',
            );
          }
          // Un 401 en login/registro significa "credenciales inválidas",
          // no "tu sesión expiró": no debe disparar el logout global ni
          // sacar al usuario de la pantalla donde está escribiendo. Antes
          // esto se activaba con cualquier 401 y mandaba al usuario a
          // Welcome a media escritura de su contraseña.
          final esAutenticacionPublica = _esRutaDeAutenticacionPublica(
            error.requestOptions.path,
          );
          if (error.response?.statusCode == 401 && !esAutenticacionPublica) {
            await _secureStorage.clearSession();
            AppNavigator.key.currentState?.pushNamedAndRemoveUntil(
              '/',
              (_) => false,
            );
          }
          handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;

  bool _esRutaDeAutenticacionPublica(String path) {
    return path.contains(AppConstants.loginEndpoint) ||
        path.contains(AppConstants.registerEndpoint);
  }

  // Despierta el servidor de Render (free tier duerme tras 15 min inactivo).
  // Llamar esto en pantallas donde el usuario tardará unos segundos antes
  // de disparar la petición real (ej. login), para esconder el cold start.
  Future<void> warmup() async {
    try {
      await _dio.get('/health').timeout(const Duration(seconds: 10));
    } catch (_) {
      // No importa si falla: lo único que se busca es mandar tráfico
      // para que Render despierte la instancia a tiempo.
    }
  }

  // ✅ 'data' ahora acepta dynamic (Map o FormData), no solo
  // Map<String, dynamic>?. Esto permite subir archivos con multipart
  // sin romper las llamadas existentes que pasan un Map normal.
  Future<Response> post(String path, {dynamic data}) async {
    try {
      if (kDebugMode) debugPrint('POST $path');
      final response = await _dio.post(path, data: data);
      return response;
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('DioError POST $path: ${e.type}');
      }
      _handleDioError(e);
    }
    throw const ServerException(message: 'Error desconocido');
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      if (kDebugMode) debugPrint('GET $path');
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('DioError GET $path: ${e.type}');
      }
      _handleDioError(e);
    }
    throw const ServerException(message: 'Error desconocido');
  }

  Future<Response> patch(String path, {Map<String, dynamic>? data}) async {
    try {
      if (kDebugMode) debugPrint('PATCH $path');
      final response = await _dio.patch(path, data: data);
      return response;
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('DioError PATCH $path: ${e.type}');
      }
      _handleDioError(e);
    }
    throw const ServerException(message: 'Error desconocido');
  }

  Future<Response> put(String path, {dynamic data}) async {
    try {
      if (kDebugMode) debugPrint('PUT $path');

      final response = await _dio.put(path, data: data);

      return response;
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('DioError PUT $path: ${e.type}');
      }

      _handleDioError(e);
    }

    throw const ServerException(
      message: 'Error desconocido hoy no duerme Abarca',
    );
  }

  Future<Response> delete(String path) async {
    try {
      if (kDebugMode) debugPrint('DELETE $path');
      final response = await _dio.delete(path);
      return response;
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('DioError DELETE $path: ${e.type}');
      }
      _handleDioError(e);
    }
    throw const ServerException(message: 'Error desconocido');
  }

  void _handleDioError(DioException e) {
    final errorStr = e.error.toString();
    if (e.type.name == 'badCertificate' ||
        e.error is HandshakeException ||
        e.error is TlsException ||
        errorStr.contains('CERTIFICATE_VERIFY_FAILED') ||
        errorStr.contains('Certificate validation failed')) {
      if (kDebugMode) {
        debugPrint(
          'HTTPS_PINNING_BLOCKED host=api-gateway-explorachiapas.onrender.com',
        );
      }
      throw const CertificatePinningException();
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        throw const NetworkException(
          message: 'Tiempo de espera agotado. Verifica tu conexion.',
        );
      case DioExceptionType.connectionError:
        throw const NetworkException(
          message: 'Sin conexion a internet. Verifica tu red.',
        );
      default:
        final statusCode = e.response?.statusCode;
        final message =
            e.response?.data?['message'] ?? e.message ?? 'Error del servidor';
        if (statusCode == 401) {
          throw UnauthorizedException(message: message);
        }
        throw ServerException(message: message, statusCode: statusCode);
    }
  }
}
