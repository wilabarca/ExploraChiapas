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

  // Ping de salud al NLP service — fire and forget.
  Future<void> warmup() async {
    try {
      await _dio.get('/warmup').timeout(const Duration(seconds: 10));
    } catch (_) {}
  }

  /// Devuelve la lista o lanza excepción — el llamador decide si mostrar error.
  Future<List<Map<String, dynamic>>> fetchDestacados({int limite = 10}) async {
    final resp = await _dio
        .get('/destacados', queryParameters: {'limite': limite})
        .timeout(const Duration(seconds: 90));
    final list = (resp.data['destacados'] as List?) ?? [];
    return list.cast<Map<String, dynamic>>();
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
