import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/categoria.dart';
import '../../domain/repositories/categorias_repository.dart';
import '../datasource/categorias_remote_datasource.dart';

@LazySingleton(as: CategoriasRepository)
class CategoriasRepositoryImpl implements CategoriasRepository {
  final CategoriasRemoteDataSource _remoteDataSource;

  const CategoriasRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<Categoria>>> getCategorias({
    String? scope,
  }) async {
    try {
      final result = await _remoteDataSource.getCategorias(scope: scope);
      return Right<Failure, List<Categoria>>(result);
    } on UnauthorizedException catch (exception) {
      return Left<Failure, List<Categoria>>(
        UnauthorizedFailure(message: exception.message),
      );
    } on NetworkException catch (exception) {
      return Left<Failure, List<Categoria>>(
        NetworkFailure(message: exception.message),
      );
    } on ServerException catch (exception) {
      return Left<Failure, List<Categoria>>(
        ServerFailure(
          message: exception.message,
          statusCode: exception.statusCode,
        ),
      );
    } catch (exception) {
      return Left<Failure, List<Categoria>>(
        ServerFailure(message: 'Ocurrió un error inesperado: $exception'),
      );
    }
  }
}
