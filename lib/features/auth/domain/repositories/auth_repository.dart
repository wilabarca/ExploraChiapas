import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/usuario.dart';
import '../entities/usuario_registro.dart';

abstract class AuthRepository {
  Future<Either<Failure, Map<String, dynamic>>> register(
      UsuarioRegistro usuario);

  Future<Either<Failure, String>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, String>> loginWithGoogle({required String idToken});

  Future<Either<Failure, Usuario>> getProfile();

  Future<Either<Failure, Usuario>> updateProfile({
    String? name,
    String? phone,
  });

  Future<Either<Failure, void>> deleteProfile();
}