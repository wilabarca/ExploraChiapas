import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_client.dart';
import '../../../../../core/utils/app_constants.dart';
import '../remote/models/promocion_model.dart';

abstract class PromocionesRemoteDataSource {
  Future<List<PromocionModel>> obtenerPromociones({String? negocioId});
}

@LazySingleton(as: PromocionesRemoteDataSource)
class PromocionesRemoteDataSourceImpl implements PromocionesRemoteDataSource {
  final ApiClient _apiClient;

  PromocionesRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<PromocionModel>> obtenerPromociones({String? negocioId}) async {
    final response = await _apiClient.get(
      AppConstants.promotionsEndpoint,
      queryParameters: {
        if (negocioId != null && negocioId.isNotEmpty) 'negocioId': negocioId,
      },
    );

    final body = response.data as Map<String, dynamic>;
    final data = body['data'] as List<dynamic>? ?? [];

    return data
        .map((e) => PromocionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
