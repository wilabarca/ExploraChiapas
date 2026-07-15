import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/app_constants.dart';
import '../../../../core/services/avatar/avatar_service.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/entities/usuario_registro.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasource/auth_remote_datasource.dart';
import 'package:flutter/foundation.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;
  final AvatarService _avatarService;

  AuthRepositoryImpl(this._dataSource, this._avatarService);

  @override
  Future<Either<Failure, Map<String, dynamic>>> register(
    UsuarioRegistro usuario,
  ) async {
    try {
      final result = await _dataSource.register(
        name: usuario.nombre,
        email: usuario.correo,
        password: usuario.contrasena,
        phone: usuario.telefono,
        userTypeId: usuario.userTypeId,
      );

      final prefs = await SharedPreferences.getInstance();

      // ← Guarda el tipo exacto que viene del enum
      await prefs.setString(
        AppConstants.tipoUsuarioKey,
        usuario
            .userTypeId, // 'turista_nacional', 'turista_extranjero' o 'habitante_local'
      );
      await prefs.setString(
        AppConstants.userNameKey,
        result['name'] as String? ?? '',
      );
      await prefs.setString(
        AppConstants.userEmailKey,
        result['email'] as String? ?? '',
      );

      // Asigna avatar según género detectado por nombre
      await _avatarService.asignarAvatarPorNombre(usuario.nombre);

      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> login({
    required String email,
    required String password,
  }) async {
    try {
      final token = await _dataSource.login(email: email, password: password);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.jwtTokenKey, token);

      // ← Al hacer login también carga el perfil para obtener el tipo
      // Si ya tiene tipo guardado de un registro previo, lo conserva
      // Si no, se asignará cuando cargue el perfil
      debugPrint('✅ Login exitoso, token guardado');
      debugPrint(
        '👤 Tipo guardado: ${prefs.getString(AppConstants.tipoUsuarioKey)}',
      );

      return Right(token);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Usuario>> getProfile() async {
    try {
      final usuario = await _dataSource.getProfile();

      // ← Cuando carga el perfil guarda el tipo del servidor
      // Esto sincroniza el tipo en caso de que haya cambiado
      final prefs = await SharedPreferences.getInstance();
      final tipoActual = prefs.getString(AppConstants.tipoUsuarioKey);

      // Solo actualiza si no hay tipo guardado
      if (tipoActual == null || tipoActual.isEmpty) {
        await prefs.setString(AppConstants.tipoUsuarioKey, usuario.userTypeId);
        debugPrint('👤 Tipo sincronizado desde perfil: ${usuario.userTypeId}');
      }

      return Right(usuario);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Usuario>> updateProfile({
    String? name,
    String? phone,
  }) async {
    try {
      final usuario = await _dataSource.updateProfile(name: name, phone: phone);
      return Right(usuario);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProfile() async {
    try {
      await _dataSource.deleteProfile();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      return const Right(null);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
