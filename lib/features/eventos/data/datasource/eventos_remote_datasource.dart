import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/app_constants.dart';
import '../models/evento_model.dart';

abstract class EventosRemoteDataSource {
  Future<List<EventoModel>> getEventos();
  Future<EventoModel> getEventoById(String id);
}

@LazySingleton(as: EventosRemoteDataSource)
class EventosRemoteDataSourceImpl implements EventosRemoteDataSource {
  final ApiClient _apiClient;

  EventosRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<EventoModel>> getEventos() async {
    final response = await _apiClient.get(AppConstants.eventsEndpoint);
    if (response.statusCode == 200) {
      final body = Map<String, dynamic>.from(response.data as Map);
      final data = body['data'];
      if (data is! List) {
        throw const ServerException(message: 'Formato inválido al obtener eventos');
      }
      return data
          .map((item) => EventoModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    }
    throw ServerException(
      message: _message(response.data, 'Error al obtener eventos'),
      statusCode: response.statusCode,
    );
  }

  @override
  Future<EventoModel> getEventoById(String id) async {
    final response = await _apiClient.get('${AppConstants.eventsEndpoint}/$id');
    if (response.statusCode == 200) {
      final body = Map<String, dynamic>.from(response.data as Map);
      final data = body['data'];
      if (data is! Map) {
        throw const ServerException(message: 'Formato inválido al obtener el evento');
      }
      return EventoModel.fromJson(Map<String, dynamic>.from(data));
    }
    throw ServerException(
      message: _message(response.data, 'Error al obtener el evento'),
      statusCode: response.statusCode,
    );
  }

  String _message(dynamic data, String fallback) {
    if (data is Map && data['message'] != null) return data['message'].toString();
    return fallback;
  }
}
