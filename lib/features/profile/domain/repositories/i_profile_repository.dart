import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/perfil_entity.dart';

abstract class IProfileRepository {
  Future<Either<Failure, PerfilEntity>> getProfile();
  Future<Either<Failure, PerfilEntity>> updateProfile({
    String? nombre,
    String? telefono,
  });
  Future<Either<Failure, void>> deleteProfile();
}