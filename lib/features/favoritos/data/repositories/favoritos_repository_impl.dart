import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/favorito.dart';
import '../../domain/repositories/favoritos_repository.dart';
import '../datasource/favoritos_remote_datasource.dart';

@LazySingleton(as: FavoritosRepository)
class FavoritosRepositoryImpl implements FavoritosRepository {
  final FavoritosRemoteDataSource _dataSource;

  FavoritosRepositoryImpl(this._dataSource);


  @override
  Future<Either<Failure, List<Favorito>>> getFavoritos() async {
    try {
      return Right(await _dataSource.getFavoritos());
    } catch (error) {
      return Left(_failure(error));
    }
  }

  @override
  Future<Either<Failure, Unit>> addFavorito({
    required String targetType,
    required String targetId,
  }) async {
    try {
      await _dataSource.addFavorito(targetType: targetType, targetId: targetId);
      return const Right(unit);
    } catch (error) {
      return Left(_failure(error));
    }
  }

  @override
  Future<Either<Failure, Unit>> removeFavorito({
    required String targetType,
    required String targetId,
  }) async {
    try {
      await _dataSource.removeFavorito(targetType: targetType, targetId: targetId);
      return const Right(unit);
    } catch (error) {
      return Left(_failure(error));
    }
  }

  Failure _failure(Object error) {
    if (error is UnauthorizedException) {
      return UnauthorizedFailure(message: error.message);
    }
    if (error is NetworkException) {
      return NetworkFailure(message: error.message);
    }
    if (error is ServerException) {
      return ServerFailure(message: error.message, statusCode: error.statusCode);
    }
    return ServerFailure(message: error.toString());
  }
}
