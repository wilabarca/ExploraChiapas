import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/favorito.dart';
import '../../domain/repositories/favoritos_repository.dart';
import '../datasource/favoritos_remote_datasource.dart';

@LazySingleton(as: FavoritosRepository)
class FavoritosRepositoryImpl implements FavoritosRepository {
  final FavoritosRemoteDataSource _remoteDataSource;

  FavoritosRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<Favorito>>> getFavoritos({
    String? targetType,
  }) async {
    try {
      final favoritos = await _remoteDataSource.getFavoritos(
        targetType: targetType,
      );
      return Right(favoritos);
    } on UnauthorizedException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Favorito>> addFavorito({
    required String targetType,
    required String targetId,
  }) async {
    try {
      final favorito = await _remoteDataSource.addFavorito(
        targetType: targetType,
        targetId: targetId,
      );
      return Right(favorito);
    } on UnauthorizedException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ServerException catch (e) {
      // El backend manda 409 con mensaje "Este elemento ya está en
      // favoritos" — ServerException ya trae ese mensaje en e.message.
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFavorito({
    required String targetType,
    required String targetId,
  }) async {
    try {
      await _remoteDataSource.removeFavorito(
        targetType: targetType,
        targetId: targetId,
      );
      return const Right(null);
    } on UnauthorizedException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ServerException catch (e) {
      // El backend manda 404 con mensaje "Favorito no encontrado".
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isFavorito({
    required String targetType,
    required String targetId,
  }) async {
    try {
      final favoritos = await _remoteDataSource.getFavoritos(
        targetType: targetType,
      );

      final existe = favoritos.any((favorito) => favorito.targetId == targetId);
      return Right(existe);
    } on UnauthorizedException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
