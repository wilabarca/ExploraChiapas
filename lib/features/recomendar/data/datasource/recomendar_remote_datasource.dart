import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/app_constants.dart';
import 'remote/models/ubicacion_sugerida_model.dart';

abstract class IRecomendarRemoteDatasource {
  Future<UbicacionSugeridaModel> sugerirLugar({
    required double latitude,
    required double longitude,
    String? address,
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
  }) async {
    final response = await _apiClient.post(
      AppConstants.locationsEndpoint,
      data: {
        'latitude': latitude,
        'longitude': longitude,
        if (address != null && address.isNotEmpty) 'address': address,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = response.data as Map<String, dynamic>;
      return UbicacionSugeridaModel.fromJson(
        body['data'] as Map<String, dynamic>,
      );
    }

    throw ServerException(
      message:
          response.data['message']?.toString() ??
          'No fue posible enviar tu recomendación',
      statusCode: response.statusCode,
    );
  }
}
