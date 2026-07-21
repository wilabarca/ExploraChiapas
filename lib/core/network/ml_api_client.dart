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
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  /// Despierta el servidor NLP en Render antes de que se necesite,
  /// ya que estos servicios se duermen tras inactividad. Best-effort:
  /// ignora cualquier error, pues solo es una optimización de latencia.
  Future<void> warmup() async {
    try {
      await _dio.get('/');
    } catch (_) {}
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
          message: 'Tiempo de espera agotado. Verifica tu conexion.',
        );
      case DioExceptionType.connectionError:
        throw const NetworkException(
          message: 'Sin conexion a internet. Verifica tu red.',
        );
      default:
        final statusCode = e.response?.statusCode;
        // nlp-service y ml-engine devuelven { "error": "..." }, no { "message": ... }
        final message =
            e.response?.data?['error'] ?? e.message ?? 'Error del servidor';
        throw ServerException(message: message.toString(), statusCode: statusCode);
    }
  }
}
