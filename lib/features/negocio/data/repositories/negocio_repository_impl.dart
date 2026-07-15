import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/negocio.dart';
import '../../domain/repositories/negocio_repository.dart';
import '../datasource/negocio_remote_datasource.dart';

@LazySingleton(as: NegocioRepository)
class NegocioRepositoryImpl implements NegocioRepository {
  final NegocioRemoteDataSource _dataSource;

  NegocioRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<Negocio>>> obtenerNegocios({
    String? tipoNegocioId,
    String? busqueda,
    bool? soloVerificados,
    double? latitud,
    double? longitud,
  }) async {
    try {
      final negocios = await _dataSource.obtenerNegocios(
        tipoNegocioId: tipoNegocioId,
        busqueda: busqueda,
        soloVerificados: soloVerificados,
        latitud: latitud,
        longitud: longitud,
      );
      return Right(negocios);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Negocio>> obtenerNegocioPorId(String id) async {
    try {
      final negocio = await _dataSource.obtenerNegocioPorId(id);
      return Right(negocio);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Negocio>>> buscarNegocios(String query) async {
    try {
      final negocios = await _dataSource.buscarNegocios(query);
      return Right(negocios);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
