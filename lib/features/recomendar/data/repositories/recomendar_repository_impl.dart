import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/propuesta_destino.dart';
import '../../domain/entities/ubicacion_sugerida.dart';
import '../../domain/repositories/i_recomendar_repository.dart';
import '../datasource/recomendar_remote_datasource.dart';

@Injectable(as: IRecomendarRepository)
class RecomendarRepositoryImpl implements IRecomendarRepository {
  final IRecomendarRemoteDatasource _datasource;
  RecomendarRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, UbicacionSugerida>> sugerirLugar({
    required double latitude,
    required double longitude,
    String? address,
    String? municipality,
    String? state,
    String? mapProvider,
  }) {
    return _ejecutar(
      () => _datasource.sugerirLugar(
        latitude: latitude,
        longitude: longitude,
        address: address,
        municipality: municipality,
        state: state,
        mapProvider: mapProvider,
      ),
    );
  }

  @override
  Future<Either<Failure, PropuestaDestino>> crearPropuesta({
    required String name,
    required String description,
    required String categoryId,
    required String locationId,
  }) {
    return _ejecutar(
      () => _datasource.crearPropuesta(
        name: name,
        description: description,
        categoryId: categoryId,
        locationId: locationId,
      ),
    );
  }

  @override
  Future<Either<Failure, PropuestaDestino>> subirImagenesPropuesta({
    required String proposalId,
    required List<String> rutasImagenes,
  }) {
    return _ejecutar(
      () => _datasource.subirImagenesPropuesta(
        proposalId: proposalId,
        rutasImagenes: rutasImagenes,
      ),
    );
  }

  @override
  Future<Either<Failure, List<PropuestaDestino>>> obtenerMisPropuestas() {
    return _ejecutar(() => _datasource.obtenerMisPropuestas());
  }

  @override
  Future<Either<Failure, void>> eliminarImagenPropuesta({
    required String proposalId,
    required String imageId,
  }) {
    return _ejecutar(
      () => _datasource.eliminarImagenPropuesta(
        proposalId: proposalId,
        imageId: imageId,
      ),
    );
  }

  Future<Either<Failure, T>> _ejecutar<T>(
    Future<T> Function() operacion,
  ) async {
    try {
      final resultado = await operacion();
      return Right(resultado);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (_) {
      return const Left(
        ServerFailure(
          message: 'Ocurrió un error inesperado. Inténtalo de nuevo.',
        ),
      );
    }
  }
}
