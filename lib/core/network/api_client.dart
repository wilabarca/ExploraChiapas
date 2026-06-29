import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../error/exceptions.dart';
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
          final token = prefs.getString('jwt_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            throw UnauthorizedException(
              message: error.response?.data['message'] ?? 'No autorizado',
            );
          }
          handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;

  Future<Response> post(String path, {Map<String, dynamic>? data}) async {
    try {
      debugPrint('POST: $_baseUrl$path');
      debugPrint('Body: $data');
      final response = await _dio.post(path, data: data);
      debugPrint('Response ${response.statusCode}: ${response.data}');
      return response;
    } on DioException catch (e) {
      debugPrint('DioError: ${e.type} - ${e.message}');
      debugPrint('Response: ${e.response?.statusCode} - ${e.response?.data}');
      _handleDioError(e);
    }
    throw const ServerException(message: 'Error desconocido');
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      _handleDioError(e);
    }
    throw const ServerException(message: 'Error desconocido');
  }

  Future<Response> patch(String path, {Map<String, dynamic>? data}) async {
    try {
      return await _dio.patch(path, data: data);
    } on DioException catch (e) {
      _handleDioError(e);
    }
    throw const ServerException(message: 'Error desconocido');
  }

  Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
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
        final message =
            e.response?.data?['message'] ?? e.message ?? 'Error del servidor';
        if (statusCode == 401) {
          throw UnauthorizedException(message: message);
        }
        throw ServerException(message: message, statusCode: statusCode);
    }
  }
}
