import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../error/exceptions.dart';
import '../navigation/app_navigator.dart';
import '../utils/app_constants.dart';

@lazySingleton
class ApiClient {
  late final Dio _dio;

  static const String _baseUrl = AppConstants.baseUrl;

  ApiClient() {
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

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString(AppConstants.jwtTokenKey);
          debugPrint(
            '🔑 JWT interceptor: ${token != null ? "SÍ (${token.length} chars)" : "❌ NO HAY TOKEN"}',
          );
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          debugPrint('➡️  ${options.method} ${options.baseUrl}${options.path}');
          debugPrint('📋 Headers: ${options.headers}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint(
            '✅ ${response.statusCode} ${response.requestOptions.path}',
          );
          handler.next(response);
        },
        onError: (error, handler) async {
          debugPrint(
            '❌ Error ${error.response?.statusCode}: ${error.response?.data}',
          );
          if (error.response?.statusCode == 401) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove(AppConstants.jwtTokenKey);
            AppNavigator.key.currentState
                ?.pushNamedAndRemoveUntil('/', (_) => false);
          }
          handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;

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
      debugPrint('📤 POST: $_baseUrl$path');
      debugPrint(
        '📦 Body: ${data is FormData ? "FormData (multipart)" : data}',
      );
      final response = await _dio.post(path, data: data);
      debugPrint('📥 Response ${response.statusCode}: ${response.data}');
      return response;
    } on DioException catch (e) {
      debugPrint('💥 DioError POST: ${e.type} - ${e.message}');
      debugPrint(
        '📥 Response: ${e.response?.statusCode} - ${e.response?.data}',
      );
      _handleDioError(e);
    }
    throw const ServerException(message: 'Error desconocido');
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      debugPrint('📤 GET: $_baseUrl$path');
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.jwtTokenKey);
      debugPrint(
        '🔑 JWT en prefs: ${token != null ? "SÍ (${token.substring(0, token.length.clamp(0, 30))}...)" : "❌ NO HAY TOKEN"}',
      );
      final response = await _dio.get(path, queryParameters: queryParameters);
      debugPrint('📥 Response ${response.statusCode}: ${response.data}');
      return response;
    } on DioException catch (e) {
      debugPrint('💥 DioError GET: ${e.type} - ${e.message}');
      debugPrint(
        '📥 Response: ${e.response?.statusCode} - ${e.response?.data}',
      );
      _handleDioError(e);
    }
    throw const ServerException(message: 'Error desconocido');
  }

  Future<Response> patch(String path, {Map<String, dynamic>? data}) async {
    try {
      debugPrint('📤 PATCH: $_baseUrl$path');
      debugPrint('📦 Body: $data');
      final response = await _dio.patch(path, data: data);
      debugPrint('📥 Response ${response.statusCode}: ${response.data}');
      return response;
    } on DioException catch (e) {
      debugPrint('💥 DioError PATCH: ${e.type} - ${e.message}');
      debugPrint(
        '📥 Response: ${e.response?.statusCode} - ${e.response?.data}',
      );
      _handleDioError(e);
    }
    throw const ServerException(message: 'Error desconocido');
  }

  Future<Response> put(
  String path, {
  dynamic data,
}) async {
  try {
    debugPrint('📤 PUT: $_baseUrl$path');
    debugPrint('📦 Body: $data');

    final response = await _dio.put(
      path,
      data: data,
    );

    debugPrint(
      '📥 Response ${response.statusCode}: ${response.data}',
    );

    return response;
  } on DioException catch (e) {
    debugPrint(
      '💥 DioError PUT: ${e.type} - ${e.message}',
    );

    debugPrint(
      '📥 Response: '
      '${e.response?.statusCode} - '
      '${e.response?.data}',
    );

    _handleDioError(e);
  }

  throw const ServerException(
    message: 'Error desconocido hoy no duerme Abarca',
  );
}

  Future<Response> delete(String path) async {
    try {
      debugPrint('📤 DELETE: $_baseUrl$path');
      final response = await _dio.delete(path);
      debugPrint('📥 Response ${response.statusCode}: ${response.data}');
      return response;
    } on DioException catch (e) {
      debugPrint('💥 DioError DELETE: ${e.type} - ${e.message}');
      debugPrint(
        '📥 Response: ${e.response?.statusCode} - ${e.response?.data}',
      );
      _handleDioError(e);
    }
    throw const ServerException(message: 'Error desconocido');
  }

  void _handleDioError(DioException e) {
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
