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

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;
  final AvatarService _avatarService; // Inyectado automaticamente por get_it

  AuthRepositoryImpl(this._dataSource, this._avatarService);

  @override
  Future<Either<Failure, Map<String, dynamic>>> register(
    UsuarioRegistro usuario,
  ) async {
    try {
      final result = await _dataSource.register(
        name:       usuario.nombre,
        email:      usuario.correo,
        password:   usuario.contrasena,
        phone:      usuario.telefono,
        userTypeId: usuario.userTypeId,
      );

      // Guarda datos del usuario localmente
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        AppConstants.tipoUsuarioKey,
        usuario.esLocal ? 'Local' : 'Turista',
      );
      await prefs.setString(
        AppConstants.userNameKey,
        result['name'] as String? ?? '',
      );
      await prefs.setString(
        AppConstants.userEmailKey,
        result['email'] as String? ?? '',
      );

      // Detecta genero por nombre y asigna avatar de DiceBear
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
      final token =
          await _dataSource.login(email: email, password: password);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.jwtTokenKey, token);

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
      final usuario =
          await _dataSource.updateProfile(name: name, phone: phone);
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