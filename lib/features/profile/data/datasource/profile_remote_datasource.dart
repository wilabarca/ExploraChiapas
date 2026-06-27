import 'package:injectable/injectable.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../datasource/remote/models/perfil_model.dart';

abstract class IProfileRemoteDatasource {
  Future<PerfilModel> getProfile();
  Future<PerfilModel> updateProfile({String? nombre, String? telefono});
  Future<void> deleteProfile();
}

@Injectable(as: IProfileRemoteDatasource)
class ProfileRemoteDatasourceImpl implements IProfileRemoteDatasource {
  final ApiClient _apiClient;
  ProfileRemoteDatasourceImpl(this._apiClient);

  @override
  Future<PerfilModel> getProfile() async {
    final response = await _apiClient.get(AppConstants.profileEndpoint);
    if (response.statusCode == 200) {
      final body = response.data as Map<String, dynamic>;
      return PerfilModel.fromJson(body['data'] as Map<String, dynamic>);
    }
    throw ServerException(
      message: response.data['message'] ?? 'Error al obtener perfil',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<PerfilModel> updateProfile({String? nombre, String? telefono}) async {
    final data = <String, dynamic>{};
    if (nombre != null) data['name'] = nombre;
    if (telefono != null) data['phone'] = telefono;

    final response = await _apiClient.patch(
      AppConstants.profileEndpoint,
      data: data,
    );
    if (response.statusCode == 200) {
      final body = response.data as Map<String, dynamic>;
      return PerfilModel.fromJson(body['data'] as Map<String, dynamic>);
    }
    throw ServerException(
      message: response.data['message'] ?? 'Error al actualizar perfil',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<void> deleteProfile() async {
    final response = await _apiClient.delete(AppConstants.profileEndpoint);
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw ServerException(
        message: response.data['message'] ?? 'Error al eliminar cuenta',
        statusCode: response.statusCode,
      );
    }
  }
}
