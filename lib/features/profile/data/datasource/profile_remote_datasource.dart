import 'dart:io';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../datasource/remote/models/perfil_model.dart';

abstract class IProfileRemoteDatasource {
  Future<PerfilModel> getProfile();

  Future<PerfilModel> updateProfile({
    String? nombre,
    String? telefono,
    String? fotoPerfilUrl,
  });

  Future<void> deleteProfile();

  /// Sube el archivo de imagen y devuelve la URL pública resultante.
  Future<String> uploadFotoPerfil(File file);
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
  Future<PerfilModel> updateProfile({
    String? nombre,
    String? telefono,
    String? fotoPerfilUrl,
  }) async {
    final data = <String, dynamic>{};
    if (nombre != null) data['name'] = nombre;
    if (telefono != null) data['phone'] = telefono;
    // ⚠️ Nombre de campo asumido — confirmar contra la respuesta real de
    // GET /users/profile.
    if (fotoPerfilUrl != null) data['profileImageUrl'] = fotoPerfilUrl;

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

  @override
  Future<String> uploadFotoPerfil(File file) async {
    // ⚠️ Suposición: el endpoint espera multipart/form-data con el
    // campo 'file'. Si el backend usa otro nombre de campo (ej. 'image',
    // 'photo'), ajusta aquí.
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      ),
    });

    final response = await _apiClient.post(
      AppConstants.uploadPerfilFotoEndpoint,
      data: formData,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = response.data as Map<String, dynamic>;
      // ⚠️ Suposición: la respuesta trae { success, data: { url } }.
      final data = body['data'] as Map<String, dynamic>?;
      final url = data?['url'] as String?;

      if (url == null || url.isEmpty) {
        throw ServerException(
          message: 'El servidor no devolvió la URL de la imagen',
          statusCode: response.statusCode,
        );
      }
      return url;
    }

    throw ServerException(
      message: response.data['message'] ?? 'Error al subir la imagen',
      statusCode: response.statusCode,
    );
  }
}