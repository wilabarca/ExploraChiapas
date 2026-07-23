import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/app_constants.dart';
import '../models/evento_model.dart';
import '../models/ubicacion_evento_model.dart';

abstract class EventosRemoteDataSource {
  Future<List<EventoModel>> getEventos({bool? proximas});

  Future<EventoModel> getEventoById({required String id});

  /// GET /locations/{ubicacionId} — ubicación real asociada a un evento.
  Future<UbicacionEventoModel> getUbicacionById({required String id});
}

@LazySingleton(as: EventosRemoteDataSource)
class EventosRemoteDataSourceImpl implements EventosRemoteDataSource {
  final ApiClient _apiClient;

  const EventosRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<EventoModel>> getEventos({bool? proximas}) async {
    final queryParameters = <String, dynamic>{};

    if (proximas != null) {
      queryParameters['proximas'] = proximas.toString();
    }

    final response = await _apiClient.get(
      AppConstants.eventsEndpoint,
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );

    if (response.statusCode != 200) {
      throw ServerException(
        message: _extractErrorMessage(
          response.data,
          'No fue posible obtener los eventos',
        ),
        statusCode: response.statusCode,
      );
    }

    try {
      final responseBody = _parseResponseBody(response.data);
      final data = responseBody['data'];

      if (data is! List) {
        throw const FormatException(
          'La propiedad "data" no contiene una lista',
        );
      }

      return data
          .map<EventoModel>((item) {
            final eventJson = _parseJsonMap(item);

            return EventoModel.fromJson(eventJson);
          })
          .toList(growable: false);
    } on FormatException catch (exception) {
      throw ServerException(
        message:
            'La respuesta de eventos tiene un formato inválido: '
            '${exception.message}',
        statusCode: response.statusCode,
      );
    } on TypeError {
      throw ServerException(
        message: 'La respuesta de eventos contiene datos incompatibles',
        statusCode: response.statusCode,
      );
    }
  }

  @override
  Future<EventoModel> getEventoById({required String id}) async {
    final normalizedId = id.trim();

    if (normalizedId.isEmpty) {
      throw const ServerException(
        message: 'El identificador del evento es obligatorio',
      );
    }

    final response = await _apiClient.get(
      '${AppConstants.eventsEndpoint}/$normalizedId',
    );

    if (response.statusCode != 200) {
      throw ServerException(
        message: _extractErrorMessage(
          response.data,
          'No fue posible obtener el evento',
        ),
        statusCode: response.statusCode,
      );
    }

    try {
      final responseBody = _parseResponseBody(response.data);
      final data = responseBody['data'];
      final eventJson = _parseJsonMap(data);

      return EventoModel.fromJson(eventJson);
    } on FormatException catch (exception) {
      throw ServerException(
        message:
            'La respuesta del evento tiene un formato inválido: '
            '${exception.message}',
        statusCode: response.statusCode,
      );
    } on TypeError {
      throw ServerException(
        message: 'La respuesta del evento contiene datos incompatibles',
        statusCode: response.statusCode,
      );
    }
  }

  @override
  Future<UbicacionEventoModel> getUbicacionById({required String id}) async {
    final normalizedId = id.trim();

    if (normalizedId.isEmpty) {
      throw const ServerException(
        message: 'El identificador de la ubicación es obligatorio',
      );
    }

    final response = await _apiClient.get(
      '${AppConstants.locationsEndpoint}/$normalizedId',
    );

    if (response.statusCode != 200) {
      throw ServerException(
        message: _extractErrorMessage(
          response.data,
          'No fue posible obtener la ubicación del evento',
        ),
        statusCode: response.statusCode,
      );
    }

    try {
      final responseBody = _parseResponseBody(response.data);
      final locationJson = _parseJsonMap(responseBody['data']);

      final ubicacion = UbicacionEventoModel.fromJson(locationJson);

      if (ubicacion.latitude.isNaN || ubicacion.longitude.isNaN) {
        throw const FormatException(
          'La ubicación no tiene coordenadas numéricas válidas',
        );
      }

      return ubicacion;
    } on FormatException catch (exception) {
      throw ServerException(
        message:
            'La respuesta de la ubicación tiene un formato inválido: '
            '${exception.message}',
        statusCode: response.statusCode,
      );
    } on TypeError {
      throw ServerException(
        message: 'La respuesta de la ubicación contiene datos incompatibles',
        statusCode: response.statusCode,
      );
    }
  }

  Map<String, dynamic> _parseResponseBody(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    throw const FormatException('La respuesta principal no es un objeto JSON');
  }

  Map<String, dynamic> _parseJsonMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    throw const FormatException('El evento no es un objeto JSON válido');
  }

  String _extractErrorMessage(dynamic responseData, String defaultMessage) {
    if (responseData is Map) {
      final message = responseData['message'];

      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString().trim();
      }
    }

    return defaultMessage;
  }
}
