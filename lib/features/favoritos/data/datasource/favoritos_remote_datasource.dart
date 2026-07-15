import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/app_constants.dart';
import '../models/favorito_model.dart';

abstract class FavoritosRemoteDataSource {
  Future<List<FavoritoModel>> getFavoritos();
  Future<void> addFavorito({required String targetType, required String targetId});
  Future<void> removeFavorito({required String targetType, required String targetId});
}

@LazySingleton(as: FavoritosRemoteDataSource)
class FavoritosRemoteDataSourceImpl implements FavoritosRemoteDataSource {
  final ApiClient _apiClient;

  FavoritosRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<FavoritoModel>> getFavoritos() async {
    final response = await _apiClient.get(AppConstants.favoritesEndpoint);
    if (response.statusCode == 200) {
      final body = Map<String, dynamic>.from(response.data as Map);
      final data = body['data'];
      if (data is! List) {
        throw const ServerException(message: 'Formato inválido al obtener favoritos');
      }
      return data
          .map((item) => FavoritoModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    }
    throw ServerException(
      message: _message(response.data, 'Error al obtener favoritos'),
      statusCode: response.statusCode,
    );
  }

  @override
  Future<void> addFavorito({required String targetType, required String targetId}) async {
    final response = await _apiClient.post(
      AppConstants.favoritesEndpoint,
      data: {'targetType': targetType, 'targetId': targetId},
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ServerException(
        message: _message(response.data, 'Error al agregar favorito'),
        statusCode: response.statusCode,
      );
    }
  }

  @override
  Future<void> removeFavorito({required String targetType, required String targetId}) async {
    final response = await _apiClient.delete(
      '${AppConstants.favoritesEndpoint}/$targetType/$targetId',
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw ServerException(
        message: _message(response.data, 'Error al eliminar favorito'),
        statusCode: response.statusCode,
      );
    }
  }

  String _message(dynamic data, String fallback) {
    if (data is Map && data['message'] != null) return data['message'].toString();
    return fallback;
  }
}
