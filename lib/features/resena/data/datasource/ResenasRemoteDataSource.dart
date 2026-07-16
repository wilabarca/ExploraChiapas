import 'package:injectable/injectable.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/utils/app_constants.dart';
import 'remote/models/ResenaModel.dart';

abstract class ResenasRemoteDataSource {
  Future<List<ResenaModel>> getResenas({
    required String targetType,
    required String targetId,
  });

  Future<ResenaModel> crearResena({
    required String targetType,
    required String targetId,
    required int rating,
    String? comment,
  });
}

@LazySingleton(as: ResenasRemoteDataSource)
class ResenasRemoteDataSourceImpl implements ResenasRemoteDataSource {
  final ApiClient _apiClient;

  ResenasRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<ResenaModel>> getResenas({
    required String targetType,
    required String targetId,
  }) async {
    // ⚠️ Verifica que ApiClient exponga `.dio` (Dio). Si tu ApiClient usa
    // otros nombres de método (p.ej. apiClient.get(...)), ajusta aquí.
    final response = await _apiClient.dio.get(
      AppConstants.reviewsEndpoint,
      queryParameters: {
        'targetType': targetType,
        'targetId': targetId,
      },
    );

    final data = response.data['data'] as List;
    return data
        .map((e) => ResenaModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ResenaModel> crearResena({
    required String targetType,
    required String targetId,
    required int rating,
    String? comment,
  }) async {
    final response = await _apiClient.dio.post(
      AppConstants.reviewsEndpoint,
      data: {
        'targetType': targetType,
        'targetId': targetId,
        'rating': rating,
        if (comment != null) 'comment': comment,
      },
    );

    return ResenaModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }
}