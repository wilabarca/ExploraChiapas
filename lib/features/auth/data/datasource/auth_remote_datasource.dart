import 'package:injectable/injectable.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../data/datasource/remote/models/usuario_model.dart';
import 'remote/models/user_interests_model.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String userTypeId,
  });

  Future<String> login({required String email, required String password});

  Future<String> loginWithGoogle({required String idToken});

  Future<UsuarioModel> getProfile();

  Future<UsuarioModel> updateProfile({String? name, String? phone});

  Future<UserInterestsModel> getUserInterests();
  Future<List<UserInterestModel>> getInterestCategories();

  Future<UserInterestsModel> updateUserInterests({
    required List<String> categoryIds,
  });
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<UserInterestsModel> getUserInterests() async {
    final response = await _apiClient.get(AppConstants.userInterestsEndpoint);

    if (response.statusCode == 200) {
      final body = response.data as Map<String, dynamic>;

      final data = body['data'] as Map<String, dynamic>;

      return UserInterestsModel.fromJson(data);
    }

    throw ServerException(
      message: response.data['message'] ?? 'Error al obtener intereses',
      statusCode: response.statusCode,
    );
  }

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
        'userType': userTypeId, // El backend espera 'userType', no 'userTypeId'
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
  Future<List<UserInterestModel>> getInterestCategories() async {
    final response = await _apiClient.get(
      AppConstants.categoriesEndpoint,
      queryParameters: {'scope': 'destinos'},
    );

    if (response.statusCode == 200) {
      final body = response.data as Map<String, dynamic>;

      final rawCategories = body['data'] as List<dynamic>? ?? [];

      return rawCategories.map((item) {
        final json = Map<String, dynamic>.from(item as Map);

        return UserInterestModel(
          id: json['id'].toString(),
          name: json['nombre']?.toString() ?? '',
          icon: json['icono']?.toString(),
        );
      }).toList();
    }

    throw ServerException(
      message: response.data['message'] ?? 'Error al obtener categorías',
      statusCode: response.statusCode,
    );
  }

  @override
  Future<UserInterestsModel> updateUserInterests({
    required List<String> categoryIds,
  }) async {
    final response = await _apiClient.put(
      AppConstants.userInterestsEndpoint,
      data: {'categoryIds': categoryIds},
    );

    if (response.statusCode == 200) {
      final body = response.data as Map<String, dynamic>;

      final data = body['data'] as Map<String, dynamic>;

      return UserInterestsModel.fromJson(data);
    }

    throw ServerException(
      message: response.data['message'] ?? 'Error al actualizar intereses',
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
  Future<String> loginWithGoogle({required String idToken}) async {
    final response = await _apiClient.post(
      '/users/google-auth',
      data: {'idToken': idToken},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = response.data as Map<String, dynamic>;
      final token = (body['data']?['token'] ?? body['token']) as String?;
      if (token == null) {
        throw const ServerException(message: 'Token no recibido del servidor');
      }
      return token;
    }

    throw ServerException(
      message: response.data['message'] ?? 'Error al autenticar con Google',
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
}
