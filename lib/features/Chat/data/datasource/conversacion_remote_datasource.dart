import 'package:injectable/injectable.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/app_constants.dart';
import '../../../../core/error/exceptions.dart';

class ConversacionModel {
  final String id;
  final String titulo;
  final DateTime actualizadoEn;

  const ConversacionModel({
    required this.id,
    required this.titulo,
    required this.actualizadoEn,
  });

  factory ConversacionModel.fromJson(Map<String, dynamic> json) {
    return ConversacionModel(
      id: json['id'] as String,
      titulo: (json['titulo'] as String?) ?? 'Nueva conversación',
      actualizadoEn: DateTime.parse(json['actualizadoEn'] as String),
    );
  }
}

class MensajeChatModel {
  final String id;
  final String rol;
  final String contenido;
  final DateTime creadoEn;

  const MensajeChatModel({
    required this.id,
    required this.rol,
    required this.contenido,
    required this.creadoEn,
  });

  factory MensajeChatModel.fromJson(Map<String, dynamic> json) {
    return MensajeChatModel(
      id: json['id'] as String,
      rol: json['rol'] as String,
      contenido: json['contenido'] as String,
      creadoEn: DateTime.parse(json['creadoEn'] as String),
    );
  }
}

class ConversacionConMensajesModel extends ConversacionModel {
  final List<MensajeChatModel> mensajes;

  const ConversacionConMensajesModel({
    required super.id,
    required super.titulo,
    required super.actualizadoEn,
    required this.mensajes,
  });

  factory ConversacionConMensajesModel.fromJson(Map<String, dynamic> json) {
    final mensajesJson = json['mensajes'] as List<dynamic>? ?? [];
    return ConversacionConMensajesModel(
      id: json['id'] as String,
      titulo: (json['titulo'] as String?) ?? 'Conversación',
      actualizadoEn: DateTime.parse(json['actualizadoEn'] as String),
      mensajes: mensajesJson
          .map((m) => MensajeChatModel.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }
}

@lazySingleton
class ConversacionRemoteDatasource {
  final ApiClient _api;

  ConversacionRemoteDatasource(this._api);

  Future<ConversacionModel> crear({String? titulo}) async {
    final response = await _api.post(
      AppConstants.conversacionesEndpoint,
      data: {'titulo': titulo},
    );
    final data = (response.data as Map<String, dynamic>)['data'];
    return ConversacionModel.fromJson(data as Map<String, dynamic>);
  }

  Future<List<ConversacionModel>> listar() async {
    final response = await _api.get(AppConstants.conversacionesEndpoint);
    final data = (response.data as Map<String, dynamic>)['data'] as List;
    return data
        .map((e) => ConversacionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ConversacionConMensajesModel> obtener(String id) async {
    final response = await _api.get('${AppConstants.conversacionesEndpoint}/$id');
    final data = (response.data as Map<String, dynamic>)['data'];
    return ConversacionConMensajesModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> agregarMensaje({
    required String conversacionId,
    required String rol,
    required String contenido,
  }) async {
    await _api.post(
      '${AppConstants.conversacionesEndpoint}/$conversacionId/mensajes',
      data: {'rol': rol, 'contenido': contenido},
    );
  }

  Future<void> eliminar(String id) async {
    await _api.delete('${AppConstants.conversacionesEndpoint}/$id');
  }
}
