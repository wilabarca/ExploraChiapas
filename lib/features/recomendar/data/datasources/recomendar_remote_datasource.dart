import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/app_constants.dart';
import '../models/categoria_model.dart';
import '../models/propuesta_destino_model.dart';
import '../../domain/entities/ubicacion_propuesta.dart';

abstract class RecomendarRemoteDataSource {
  Future<List<CategoriaModel>> getCategorias();
  Future<String> crearUbicacion(UbicacionPropuesta ubicacion);
  Future<PropuestaDestinoModel> crearPropuesta({
    required String name,
    required String description,
    required String categoryId,
    required String locationId,
  });
  Future<void> subirImagenes({
    required String proposalId,
    required List<XFile> imagenes,
  });
  Future<List<PropuestaDestinoModel>> getMisPropuestas();
}

@LazySingleton(as: RecomendarRemoteDataSource)
class RecomendarRemoteDataSourceImpl implements RecomendarRemoteDataSource {
  final ApiClient _apiClient;

  RecomendarRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<CategoriaModel>> getCategorias() async {
    final response = await _apiClient.get(
      AppConstants.categoriesEndpoint,
      queryParameters: {'scope': 'destinos'},
    );

    if (response.statusCode == 200) {
      final data = _extractData(response.data);
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(CategoriaModel.fromJson)
            .toList();
      }
      throw const ServerException(message: 'Formato de categorías inválido');
    }
    throw ServerException(
      message: _extractMessage(response.data, 'Error al obtener categorías'),
      statusCode: response.statusCode,
    );
  }

  @override
  Future<String> crearUbicacion(UbicacionPropuesta ubicacion) async {
    final body = {
      'latitude': ubicacion.latitude,
      'longitude': ubicacion.longitude,
      'address': ubicacion.address,
      'municipality': ubicacion.municipality,
      'state': ubicacion.state,
      'mapProvider': ubicacion.mapProvider,
    };

    final response = await _apiClient.post(
      AppConstants.locationsEndpoint,
      data: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = _extractData(response.data);
      if (data is Map) {
        final id = data['id']?.toString();
        if (id != null && id.isNotEmpty) return id;
      }
      throw const ServerException(message: 'El servidor no devolvió un ID de ubicación');
    }
    throw ServerException(
      message: _extractMessage(response.data, 'Error al crear la ubicación'),
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
    final body = {
      'name': name,
      'description': description,
      'categoryId': categoryId,
      'locationId': locationId,
    };

    final response = await _apiClient.post(
      AppConstants.destinationProposalsEndpoint,
      data: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = _extractData(response.data);
      if (data is Map<String, dynamic>) {
        return PropuestaDestinoModel.fromJson(data);
      }
      throw const ServerException(message: 'Respuesta de propuesta con formato inválido');
    }
    throw ServerException(
      message: _extractMessage(response.data, 'Error al crear la propuesta'),
      statusCode: response.statusCode,
    );
  }

  @override
  Future<void> subirImagenes({
    required String proposalId,
    required List<XFile> imagenes,
  }) async {
    final formData = FormData();
    for (final img in imagenes) {
      formData.files.add(MapEntry(
        'imagenes',
        await MultipartFile.fromFile(img.path, filename: img.name),
      ));
    }

    final response = await _apiClient.post(
      '${AppConstants.destinationProposalsEndpoint}/$proposalId/images',
      data: formData,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ServerException(
        message: _extractMessage(response.data, 'Error al subir las fotografías'),
        statusCode: response.statusCode,
      );
    }
  }

  @override
  Future<List<PropuestaDestinoModel>> getMisPropuestas() async {
    final response = await _apiClient.get(
      '${AppConstants.destinationProposalsEndpoint}/mine',
    );

    if (response.statusCode == 200) {
      final data = _extractData(response.data);
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(PropuestaDestinoModel.fromJson)
            .toList();
      }
      throw const ServerException(message: 'Formato de propuestas inválido');
    }
    throw ServerException(
      message: _extractMessage(response.data, 'Error al obtener tus recomendaciones'),
      statusCode: response.statusCode,
    );
  }

  dynamic _extractData(dynamic responseData) {
    if (responseData is Map) return responseData['data'];
    return null;
  }

  String _extractMessage(dynamic responseData, String defaultMessage) {
    if (responseData is Map) {
      final msg = responseData['message'];
      if (msg != null && msg.toString().trim().isNotEmpty) {
        return msg.toString();
      }
    }
    return defaultMessage;
  }
}
