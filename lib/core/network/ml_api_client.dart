import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../error/exceptions.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../utils/app_constants.dart';
import 'gateway_certificate_pinning.dart';

@lazySingleton
class MlApiClient {
  late final Dio _dio;

  static const String _baseUrl = AppConstants.mlServiceBaseUrl;

  MlApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.mlReceiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.httpClientAdapter = GatewayCertificatePinning.createAdapter();

    _dio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) {
          if (kDebugMode) {
            final gateway = response.headers.value('x-gateway');
            if (gateway != null) {
              debugPrint('X-Gateway: $gateway');
            }
          }
          handler.next(response);
        },
      ),
    );
  }

  // Despierta tanto el NLP service como el motor ML (ambos en Render free tier).
  // Llamar esto cuando el usuario abre la pantalla de chat.
  Future<void> warmup() async {
    try {
      await _dio.get('/warmup').timeout(const Duration(seconds: 15));
    } catch (_) {
      // silencioso — es solo un ping preventivo
    }
  }

  /// Devuelve la lista o lanza excepción — el llamador decide si mostrar error.
  Future<List<Map<String, dynamic>>> fetchDestacados({int limite = 10}) async {
    try {
      // El NLP service en Render free tier puede tardar ~50s en despertar.
      // Se usan 70s para dar margen suficiente tras cold start.
      final resp = await _dio
          .get('/destacados', queryParameters: {'limite': limite})
          .timeout(const Duration(seconds: 70));
      final list = (resp.data['destacados'] as List?) ?? [];
      return list.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      _handleDioError(e);
    }
    throw const ServerException(message: 'Error desconocido');
  }

  Future<Response> post(String path, {Map<String, dynamic>? data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
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
          message:
              'El servidor tardó demasiado en responder. Intenta de nuevo.',
        );
      case DioExceptionType.connectionError:
        throw const NetworkException(
          message: 'Sin conexión a internet. Verifica tu red.',
        );
      default:
        final statusCode = e.response?.statusCode;
        final message =
            e.response?.data?['error'] ?? e.message ?? 'Error del servidor';
        throw ServerException(
          message: message.toString(),
          statusCode: statusCode,
        );
    }
  }
}
