import 'package:injectable/injectable.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/utils/app_constants.dart';
import './remote/models/favorito_model.dart';

abstract class FavoritosRemoteDataSource {
  Future<List<FavoritoModel>> getFavoritos({String? targetType});

  Future<FavoritoModel> addFavorito({
    required String targetType,
    required String targetId,
  });

  Future<void> removeFavorito({
    required String targetType,
    required String targetId,
  });
}

@LazySingleton(as: FavoritosRemoteDataSource)
class FavoritosRemoteDataSourceImpl implements FavoritosRemoteDataSource {
  final ApiClient _apiClient;

  FavoritosRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<FavoritoModel>> getFavoritos({String? targetType}) async {
    final response = await _apiClient.get(
      AppConstants.favoritesEndpoint,
      queryParameters: targetType != null ? {'targetType': targetType} : null,
    );

    final data = response.data['data'] as List;
    return data
        .map((e) => FavoritoModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<FavoritoModel> addFavorito({
    required String targetType,
    required String targetId,
  }) async {
    final response = await _apiClient.post(
      AppConstants.favoritesEndpoint,
      data: {'targetType': targetType, 'targetId': targetId},
    );

    return FavoritoModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<void> removeFavorito({
    required String targetType,
    required String targetId,
  }) async {
    // DELETE /v1/api/favorites/:targetType/:targetId
    await _apiClient.delete(
      '${AppConstants.favoritesEndpoint}/$targetType/$targetId',
    );
  }
}
