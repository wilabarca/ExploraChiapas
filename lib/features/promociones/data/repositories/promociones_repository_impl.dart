import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/promocion.dart';
import '../../domain/repositories/promociones_repository.dart';
import '../datasource/remote/promociones_remote_datasource.dart';

@LazySingleton(as: PromocionesRepository)
class PromocionesRepositoryImpl implements PromocionesRepository {
  final PromocionesRemoteDataSource _dataSource;

  PromocionesRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<PromocionEntity>>> getPromociones({
    String? negocioId,
  }) async {
    try {
      final promociones = await _dataSource.obtenerPromociones(
        negocioId: negocioId,
      );
      return Right(promociones);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
