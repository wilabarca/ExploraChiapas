import 'package:injectable/injectable.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../data/datasource/remote/models/usuario_model.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String userTypeId,
  });

  Future<String> login({required String email, required String password});

  Future<UsuarioModel> getProfile();

  Future<UsuarioModel> updateProfile({String? name, String? phone});

  Future<void> deleteProfile();
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String userTypeId,
  }) async {
    final response = await _apiClient.post(
      AppConstants.registerEndpoint,
      data: {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'userType': userTypeId, // ← campo correcto según la API
      },
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final body = response.data as Map<String, dynamic>;
      // La API devuelve { success: true, data: { ...usuario } }
      return body['data'] as Map<String, dynamic>;
    }

    throw ServerException(
      message: response.data['message'] ?? 'Error al registrar usuario',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<String> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      AppConstants.loginEndpoint,
      data: {'email': email, 'password': password},
    );

    if (response.statusCode == 200) {
      final body = response.data as Map<String, dynamic>;
      final token = (body['data']?['token'] ?? body['token']) as String?;
      if (token == null) {
        throw const ServerException(message: 'Token no recibido del servidor');
      }
      return token;
    }

    throw ServerException(
      message: response.data['message'] ?? 'Error al iniciar sesion',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<UsuarioModel> getProfile() async {
    final response = await _apiClient.get(AppConstants.profileEndpoint);

    if (response.statusCode == 200) {
      final body = response.data as Map<String, dynamic>;
      return UsuarioModel.fromJson(body['data'] as Map<String, dynamic>);
    }

    throw ServerException(
      message: response.data['message'] ?? 'Error al obtener perfil',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<UsuarioModel> updateProfile({String? name, String? phone}) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (phone != null) data['phone'] = phone;

    final response = await _apiClient.patch(
      AppConstants.profileEndpoint,
      data: data,
    );

    if (response.statusCode == 200) {
      final body = response.data as Map<String, dynamic>;
      return UsuarioModel.fromJson(body['data'] as Map<String, dynamic>);
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
