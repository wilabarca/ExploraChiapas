import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/categoria.dart';
import '../../domain/entities/propuesta_destino.dart';
import '../../domain/entities/ubicacion_propuesta.dart';
import '../../domain/repositories/recomendar_repository.dart';
import '../datasources/recomendar_remote_datasource.dart';

@LazySingleton(as: RecomendarRepository)
class RecomendarRepositoryImpl implements RecomendarRepository {
  final RecomendarRemoteDataSource _remoteDataSource;

  const RecomendarRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<Categoria>>> getCategorias() {
    return _execute(() => _remoteDataSource.getCategorias());
  }

  @override
  Future<Either<Failure, String>> crearUbicacion(UbicacionPropuesta ubicacion) {
    return _execute(() => _remoteDataSource.crearUbicacion(ubicacion));
  }

  @override
  Future<Either<Failure, PropuestaDestino>> crearPropuesta({
    required String name,
    required String description,
    required String categoryId,
    required String locationId,
  }) {
    return _execute(() => _remoteDataSource.crearPropuesta(
          name: name,
          description: description,
          categoryId: categoryId,
          locationId: locationId,
        ));
  }

  @override
  Future<Either<Failure, void>> subirImagenes({
    required String proposalId,
    required List<XFile> imagenes,
  }) {
    return _execute(() => _remoteDataSource.subirImagenes(
          proposalId: proposalId,
          imagenes: imagenes,
        ));
  }

  @override
  Future<Either<Failure, List<PropuestaDestino>>> getMisPropuestas() {
    return _execute(() => _remoteDataSource.getMisPropuestas());
  }

  Future<Either<Failure, T>> _execute<T>(Future<T> Function() operation) async {
    try {
      return Right(await operation());
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }
}
