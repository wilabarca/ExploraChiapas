import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/app_constants.dart';
import 'remote/models/propuesta_destino_model.dart';
import 'remote/models/ubicacion_sugerida_model.dart';

abstract class IRecomendarRemoteDatasource {
  /// POST /v1/api/locations — crea la ubicación real (paso 1 del flujo
  /// de "Recomendar lugar"). Devuelve el `location.id` a usar como
  /// `locationId` al crear la propuesta.
  Future<UbicacionSugeridaModel> sugerirLugar({
    required double latitude,
    required double longitude,
    String? address,
    String? municipality,
    String? state,
    String? mapProvider,
  });

  /// POST /v1/api/destination-proposals — crea la propuesta de destino
  /// (paso 2). Requiere una ubicación ya creada (`locationId`).
  Future<PropuestaDestinoModel> crearPropuesta({
    required String name,
    required String description,
    required String categoryId,
    required String locationId,
  });

  /// POST /v1/api/destination-proposals/{id}/images — sube de 1 a 5
  /// fotos (paso 3), todas bajo el campo multipart `imagenes`.
  Future<PropuestaDestinoModel> subirImagenesPropuesta({
    required String proposalId,
    required List<String> rutasImagenes,
  });

  /// GET /v1/api/destination-proposals/mine — propuestas del usuario
  /// autenticado, para la pantalla "Mis recomendaciones".
  Future<List<PropuestaDestinoModel>> obtenerMisPropuestas();

  /// DELETE /v1/api/destination-proposals/{id}/images/{imageId}.
  Future<void> eliminarImagenPropuesta({
    required String proposalId,
    required String imageId,
  });
}

@LazySingleton(as: IRecomendarRemoteDatasource)
class RecomendarRemoteDatasourceImpl implements IRecomendarRemoteDatasource {
  final ApiClient _apiClient;
  RecomendarRemoteDatasourceImpl(this._apiClient);

  @override
  Future<UbicacionSugeridaModel> sugerirLugar({
    required double latitude,
    required double longitude,
    String? address,
    String? municipality,
    String? state,
    String? mapProvider,
  }) async {
    final response = await _apiClient.post(
      AppConstants.locationsEndpoint,
      data: {
        'latitude': latitude,
        'longitude': longitude,
        if (address != null && address.isNotEmpty) 'address': address,
        if (municipality != null && municipality.isNotEmpty)
          'municipality': municipality,
        if (state != null && state.isNotEmpty) 'state': state,
        if (mapProvider != null && mapProvider.isNotEmpty)
          'mapProvider': mapProvider,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = response.data as Map<String, dynamic>;
      return UbicacionSugeridaModel.fromJson(
        body['data'] as Map<String, dynamic>,
      );
    }

    throw ServerException(
      message: _extractErrorMessage(
        response.data,
        'No fue posible registrar la ubicación',
      ),
      statusCode: response.statusCode,
    );
  }

  @override
  Future<PropuestaDestinoModel> crearPropuesta({
    required String name,
    required String description,
    required String categoryId,
    required String locationId,
  }) async {
    final response = await _apiClient.post(
      AppConstants.destinationProposalsEndpoint,
      data: {
        'name': name,
        'description': description,
        'categoryId': categoryId,
        'locationId': locationId,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = response.data as Map<String, dynamic>;
      return PropuestaDestinoModel.fromJson(
        body['data'] as Map<String, dynamic>,
      );
    }

    throw ServerException(
      message: _extractErrorMessage(
        response.data,
        'No fue posible registrar tu recomendación',
      ),
      statusCode: response.statusCode,
    );
  }

  @override
  Future<PropuestaDestinoModel> subirImagenesPropuesta({
    required String proposalId,
    required List<String> rutasImagenes,
  }) async {
    final formData = FormData();

    for (final ruta in rutasImagenes) {
      formData.files.add(
        MapEntry(
          AppConstants.destinationProposalImagesField,
          await MultipartFile.fromFile(ruta, filename: ruta.split('/').last),
        ),
      );
    }

    final response = await _apiClient.post(
      '${AppConstants.destinationProposalsEndpoint}/$proposalId/images',
      data: formData,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = response.data as Map<String, dynamic>;
      return PropuestaDestinoModel.fromJson(
        body['data'] as Map<String, dynamic>,
      );
    }

    throw ServerException(
      message: _extractErrorMessage(
        response.data,
        'No fue posible subir las fotografías',
      ),
      statusCode: response.statusCode,
    );
  }

  @override
  Future<List<PropuestaDestinoModel>> obtenerMisPropuestas() async {
    final response = await _apiClient.get(
      '${AppConstants.destinationProposalsEndpoint}/mine',
    );

    if (response.statusCode == 200) {
      final body = response.data as Map<String, dynamic>;
      final data = body['data'];

      if (data is! List) {
        throw const ServerException(
          message: 'La API no devolvió una lista de recomendaciones',
        );
      }

      return data
          .whereType<Map<String, dynamic>>()
          .map(PropuestaDestinoModel.fromJson)
          .toList(growable: false);
    }

    throw ServerException(
      message: _extractErrorMessage(
        response.data,
        'No fue posible obtener tus recomendaciones',
      ),
      statusCode: response.statusCode,
    );
  }

  @override
  Future<void> eliminarImagenPropuesta({
    required String proposalId,
    required String imageId,
  }) async {
    final response = await _apiClient.delete(
      '${AppConstants.destinationProposalsEndpoint}/$proposalId/images/$imageId',
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw ServerException(
        message: _extractErrorMessage(
          response.data,
          'No fue posible eliminar la fotografía',
        ),
        statusCode: response.statusCode,
      );
    }
  }

  String _extractErrorMessage(dynamic responseData, String defaultMessage) {
    if (responseData is Map) {
      final message = responseData['message'];
      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString();
      }
    }
    return defaultMessage;
  }
}
