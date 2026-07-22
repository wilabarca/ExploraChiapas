import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/storage/secure_session_storage.dart';
import '../../domain/entities/user_interests.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/entities/usuario_registro.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasource/auth_remote_datasource.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;
  final SecureSessionStorage _secureStorage;

  AuthRepositoryImpl(this._dataSource, this._secureStorage);

  // ─────────────────────────────────────────────────────────────
  // REGISTRO
  // ─────────────────────────────────────────────────────────────

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

      await _secureStorage.setTipoUsuario(usuario.userTypeId);
      await _secureStorage.setUserName(result['name'] as String? ?? '');
      await _secureStorage.setUserEmail(result['email'] as String? ?? '');

      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // ─────────────────────────────────────────────────────────────
  // LOGIN
  // ─────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, String>> login({
    required String email,
    required String password,
  }) async {
    try {
      final token = await _dataSource.login(email: email, password: password);

      await _secureStorage.setToken(token);

      debugPrint('✅ Login exitoso, token guardado');

      debugPrint(
        '👤 Tipo guardado: '
        '${await _secureStorage.getTipoUsuario()}',
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
  Future<Either<Failure, String>> loginWithGoogle({
    required String idToken,
  }) async {
    try {
      final token = await _dataSource.loginWithGoogle(idToken: idToken);

      await _secureStorage.setToken(token);

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

  // ─────────────────────────────────────────────────────────────
  // INTERESES DEL USUARIO
  // ─────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, UserInterests>> getUserInterests() async {
    try {
      final result = await _dataSource.getUserInterests();

      return Right(result);
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
  Future<Either<Failure, UserInterests>> updateUserInterests({
    required List<String> categoryIds,
  }) async {
    try {
      final result = await _dataSource.updateUserInterests(
        categoryIds: categoryIds,
      );

      return Right(result);
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

  // ─────────────────────────────────────────────────────────────
  // CATEGORÍAS DISPONIBLES PARA INTERESES
  // ─────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<UserInterest>>> getInterestCategories() async {
    try {
      final result = await _dataSource.getInterestCategories();

      return Right(result);
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

  // ─────────────────────────────────────────────────────────────
  // PERFIL
  // ─────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, Usuario>> getProfile() async {
    try {
      final usuario = await _dataSource.getProfile();

      debugPrint(
        '🔍 userTypeId RAW del backend: '
        '"${usuario.userTypeId}"',
      );

      final tipoActual = await _secureStorage.getTipoUsuario();

      if (tipoActual == null || tipoActual.isEmpty) {
        await _secureStorage.setTipoUsuario(usuario.userTypeId);

        debugPrint(
          '👤 Tipo sincronizado desde perfil: '
          '${usuario.userTypeId}',
        );
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
}
