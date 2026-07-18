import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/destino.dart';
import '../datasource/destinos_remote_datasource.dart';
import '../../domain/repositories/destinos_repository.dart';

@LazySingleton(as: DestinoRepository)
class DestinoRepositoryImpl implements DestinoRepository {
  final DestinoRemoteDataSource _remoteDataSource;

  const DestinoRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<Destino>>> getDestinos({
    String? categoryId,
    String? locationId,
    String? municipality,
    String? state,
    int limit = 50,
    int offset = 0,
  }) {
    return _execute<List<Destino>>(
      () => _remoteDataSource.getDestinos(
        categoryId: categoryId,
        locationId: locationId,
        municipality: municipality,
        state: state,
        limit: limit,
        offset: offset,
      ),
    );
  }

  @override
  Future<Either<Failure, Destino>> getDestinoById({
    required String id,
  }) {
    return _execute<Destino>(
      () => _remoteDataSource.getDestinoById(id: id),
    );
  }

  Future<Either<Failure, T>> _execute<T>(
    Future<T> Function() operation,
  ) async {
    try {
      final result = await operation();

      return Right<Failure, T>(result);
    } on UnauthorizedException catch (exception) {
      return Left<Failure, T>(
        UnauthorizedFailure(
          message: exception.message,
        ),
      );
    } on NetworkException catch (exception) {
      return Left<Failure, T>(
        NetworkFailure(
          message: exception.message,
        ),
      );
    } on ServerException catch (exception) {
      return Left<Failure, T>(
        ServerFailure(
          message: exception.message,
          statusCode: exception.statusCode,
        ),
      );
    } catch (exception) {
      return Left<Failure, T>(
        ServerFailure(
          message: 'Ocurrió un error inesperado: $exception',
        ),
      );
    }
  }
}