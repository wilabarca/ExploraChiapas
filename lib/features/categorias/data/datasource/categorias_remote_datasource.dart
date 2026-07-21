import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/app_constants.dart';
import 'remote/models/categoria_model.dart';

abstract class CategoriasRemoteDataSource {
  Future<List<CategoriaModel>> getCategorias({String? scope});
}

@LazySingleton(as: CategoriasRemoteDataSource)
class CategoriasRemoteDataSourceImpl implements CategoriasRemoteDataSource {
  final ApiClient _apiClient;

  CategoriasRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<CategoriaModel>> getCategorias({String? scope}) async {
    final response = await _apiClient.get(
      AppConstants.categoriesEndpoint,
      queryParameters: scope != null ? {'scope': scope} : null,
    );

    if (response.statusCode == 200) {
      final responseBody = response.data;

      if (responseBody is! Map<String, dynamic>) {
        throw const ServerException(
          message: 'La respuesta de categorías no tiene un formato válido',
        );
      }

      final data = responseBody['data'];

      if (data is! List) {
        throw const ServerException(
          message: 'La API no devolvió una lista de categorías',
        );
      }

      return data
          .map<CategoriaModel>(
            (item) => CategoriaModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(growable: false);
    }

    throw ServerException(
      message: _extractErrorMessage(
        response.data,
        'Error al obtener las categorías',
      ),
      statusCode: response.statusCode,
    );
  }

  String _extractErrorMessage(dynamic responseData, String defaultMessage) {
    if (responseData is Map) {
      final message = responseData['message'];
      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString();
      }
    }
    return defaultMessage;
  }
}
