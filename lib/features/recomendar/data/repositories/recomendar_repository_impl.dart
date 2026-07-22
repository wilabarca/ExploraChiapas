import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
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
  }) async {
    try {
      final ubicacion = await _datasource.sugerirLugar(
        latitude: latitude,
        longitude: longitude,
        address: address,
      );
      return Right(ubicacion);
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
