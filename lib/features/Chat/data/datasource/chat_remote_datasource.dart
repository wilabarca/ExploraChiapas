import 'package:injectable/injectable.dart';
import '../../../../core/network/ml_api_client.dart';
import '../../../../core/utils/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/recomendacion_model.dart';

abstract class IChatRemoteDatasource {
  Future<RecomendacionModel> enviarMensaje(
    String texto, {
    List<Map<String, String>> historial = const [],
    double? userLat,
    double? userLng,
  });
}

@LazySingleton(as: IChatRemoteDatasource)
class ChatRemoteDatasourceImpl implements IChatRemoteDatasource {
  final MlApiClient _mlApiClient;

  ChatRemoteDatasourceImpl(this._mlApiClient);

  @override
  Future<RecomendacionModel> enviarMensaje(
    String texto, {
    List<Map<String, String>> historial = const [],
    double? userLat,
    double? userLng,
  }) async {
    final body = <String, dynamic>{
      'texto': texto,
      'historial': historial,
      if (userLat != null) 'user_lat': userLat,
      if (userLng != null) 'user_lng': userLng,
    };
    final response = await _mlApiClient.post(
      AppConstants.planearEndpoint,
      data: body,
    );

    if (response.statusCode == 200) {
      return RecomendacionModel.fromJson(response.data as Map<String, dynamic>);
    }

    final rawError = (response.data['error'] as String?) ?? '';
    throw ServerException(
      message: _mensajeAmigable(rawError),
      statusCode: response.statusCode,
    );
  }

  static String _mensajeAmigable(String raw) {
    if (raw.contains('Capa 1') || raw.contains('esquema esperado') || raw.contains('enum')) {
      return 'No pude entender bien tu solicitud. '
          'Intenta describir: ¿a dónde quieres ir, cuántas personas viajan, '
          'cuál es tu presupuesto y cuánto tiempo tienes?';
    }
    if (raw.contains('Capa 2') || raw.contains('motor ML') || raw.contains('ML Engine')) {
      return 'El motor de recomendaciones está tardando. Intenta de nuevo en unos segundos.';
    }
    if (raw.isEmpty) {
      return 'No pude generar tu itinerario. Intenta de nuevo.';
    }
    return raw;
  }
}
