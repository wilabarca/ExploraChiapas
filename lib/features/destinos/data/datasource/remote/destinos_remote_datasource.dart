import 'package:injectable/injectable.dart';

import '../../../../../core/error/exceptions.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/utils/app_constants.dart';
import '../../models/destino_model.dart';

abstract class DestinoRemoteDataSource {
  Future<List<DestinoModel>> getDestinos({
    String? categoryId,
    String? locationId,
    String? municipality,
    String? state,
    int limit = 50,
    int offset = 0,
  });

  Future<DestinoModel> getDestinoById({
    required String id,
  });
}

@LazySingleton(as: DestinoRemoteDataSource)
class DestinoRemoteDataSourceImpl implements DestinoRemoteDataSource {
  final ApiClient _apiClient;

  DestinoRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<DestinoModel>> getDestinos({
    String? categoryId,
    String? locationId,
    String? municipality,
    String? state,
    int limit = 50,
    int offset = 0,
  }) async {
    final queryParameters = <String, dynamic>{
      'limit': limit,
      'offset': offset,
    };

    if (categoryId != null && categoryId.trim().isNotEmpty) {
      queryParameters['categoryId'] = categoryId.trim();
    }

    if (locationId != null && locationId.trim().isNotEmpty) {
      queryParameters['locationId'] = locationId.trim();
    }

    if (municipality != null && municipality.trim().isNotEmpty) {
      queryParameters['municipality'] = municipality.trim();
    }

    if (state != null && state.trim().isNotEmpty) {
      queryParameters['state'] = state.trim();
    }

    final response = await _apiClient.get(
      AppConstants.destinationsEndpoint,
      queryParameters: queryParameters,
    );

    if (response.statusCode == 200) {
      final responseBody = response.data;

      if (responseBody is! Map<String, dynamic>) {
        throw const ServerException(
          message: 'La respuesta de destinos no tiene un formato válido',
        );
      }

      final data = responseBody['data'];

      if (data is! List) {
        throw const ServerException(
          message: 'La API no devolvió una lista de destinos',
        );
      }

      return data.map<DestinoModel>((item) {
        if (item is Map<String, dynamic>) {
          return DestinoModel.fromJson(item);
        }

        if (item is Map) {
          return DestinoModel.fromJson(
            Map<String, dynamic>.from(item),
          );
        }

        throw const ServerException(
          message: 'Uno de los destinos tiene un formato inválido',
        );
      }).toList(growable: false);
    }

    throw ServerException(
      message: _extractErrorMessage(
        response.data,
        'Error al obtener los destinos',
      ),
      statusCode: response.statusCode,
    );
  }

  @override
  Future<DestinoModel> getDestinoById({
    required String id,
  }) async {
    final normalizedId = id.trim();

    if (normalizedId.isEmpty) {
      throw const ServerException(
        message: 'El identificador del destino es obligatorio',
      );
    }

    final response = await _apiClient.get(
      '${AppConstants.destinationsEndpoint}/$normalizedId',
    );

    if (response.statusCode == 200) {
      final responseBody = response.data;

      if (responseBody is! Map<String, dynamic>) {
        throw const ServerException(
          message: 'La respuesta del destino no tiene un formato válido',
        );
      }

      final data = responseBody['data'];

      if (data is Map<String, dynamic>) {
        return DestinoModel.fromJson(data);
      }

      if (data is Map) {
        return DestinoModel.fromJson(
          Map<String, dynamic>.from(data),
        );
      }

      throw const ServerException(
        message: 'La API no devolvió un destino válido',
      );
    }

    throw ServerException(
      message: _extractErrorMessage(
        response.data,
        'Error al obtener el destino',
      ),
      statusCode: response.statusCode,
    );
  }

  String _extractErrorMessage(
    dynamic responseData,
    String defaultMessage,
  ) {
    if (responseData is Map) {
      final message = responseData['message'];

      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString();
      }
    }

    return defaultMessage;
  }
}