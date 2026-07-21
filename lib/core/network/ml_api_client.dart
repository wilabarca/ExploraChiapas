import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../error/exceptions.dart';
import '../utils/app_constants.dart';

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
  }

  // Despierta tanto el NLP service como el motor ML (ambos en Render free tier).
  // Llamar esto cuando el usuario abre la pantalla de chat.
  Future<void> warmup() async {
    try {
      await _dio
          .get('/warmup')
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      // silencioso — es solo un ping preventivo
    }
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
            message: message.toString(), statusCode: statusCode);
    }
  }
}
