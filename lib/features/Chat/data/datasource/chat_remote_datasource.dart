import 'package:injectable/injectable.dart';
import '../../../../core/network/ml_api_client.dart';
import '../../../../core/utils/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/recomendacion_model.dart';

abstract class IChatRemoteDatasource {
  Future<RecomendacionModel> enviarMensaje(String texto);
}

@LazySingleton(as: IChatRemoteDatasource)
class ChatRemoteDatasourceImpl implements IChatRemoteDatasource {
  final MlApiClient _mlApiClient;

  ChatRemoteDatasourceImpl(this._mlApiClient);

  @override
  Future<RecomendacionModel> enviarMensaje(String texto) async {
    final response = await _mlApiClient.post(
      AppConstants.planearEndpoint,
      data: {'texto': texto},
    );

    if (response.statusCode == 200) {
      return RecomendacionModel.fromJson(response.data as Map<String, dynamic>);
    }

    throw ServerException(
      message: response.data['error'] ?? 'Error al generar la recomendacion',
      statusCode: response.statusCode,
    );
  }
}
