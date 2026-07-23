import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/perfil_entity.dart';
import '../../domain/repositories/i_profile_repository.dart';
import '../datasource/profile_remote_datasource.dart';

@Injectable(as: IProfileRepository)
class ProfileRepositoryImpl implements IProfileRepository {
  final IProfileRemoteDatasource _datasource;
  ProfileRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, PerfilEntity>> getProfile() async {
    try {
      final model = await _datasource.getProfile();
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PerfilEntity>> updateProfile({
    String? nombre,
    String? telefono,
    String? fotoPerfilUrl,
  }) async {
    try {
      final model = await _datasource.updateProfile(
        nombre: nombre,
        telefono: telefono,
        fotoPerfilUrl: fotoPerfilUrl,
      );
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProfile() async {
    try {
      await _datasource.deleteProfile();
      return const Right(null);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (_) {
      // Excepción no anticipada (ni de red, ni de auth, ni del servidor):
      // se devuelve un mensaje amigable en vez de filtrar detalles internos.
      return const Left(
        ServerFailure(
          message: 'Ocurrió un error inesperado. Inténtalo de nuevo.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, String>> uploadFotoPerfil(File file) async {
    try {
      final url = await _datasource.uploadFotoPerfil(file);
      return Right(url);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
