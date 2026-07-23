import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/evento.dart';
import '../../domain/entities/ubicacion_evento.dart';
import '../../domain/repositories/eventos_repository.dart';
import '../datasource/eventos_remote_datasource.dart';

@LazySingleton(as: EventosRepository)
class EventosRepositoryImpl implements EventosRepository {
  final EventosRemoteDataSource _remoteDataSource;

  const EventosRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<Evento>>> getEventos({bool? proximas}) {
    return _execute<List<Evento>>(
      () => _remoteDataSource.getEventos(proximas: proximas),
    );
  }

  @override
  Future<Either<Failure, Evento>> getEventoById({required String id}) {
    return _execute<Evento>(() => _remoteDataSource.getEventoById(id: id));
  }

  @override
  Future<Either<Failure, UbicacionEvento>> getUbicacionById({
    required String id,
  }) {
    return _execute<UbicacionEvento>(
      () => _remoteDataSource.getUbicacionById(id: id),
    );
  }

  Future<Either<Failure, T>> _execute<T>(Future<T> Function() operation) async {
    try {
      final result = await operation();

      return Right<Failure, T>(result);
    } on UnauthorizedException catch (exception) {
      return Left<Failure, T>(UnauthorizedFailure(message: exception.message));
    } on NetworkException catch (exception) {
      return Left<Failure, T>(NetworkFailure(message: exception.message));
    } on ServerException catch (exception) {
      return Left<Failure, T>(
        ServerFailure(
          message: exception.message,
          statusCode: exception.statusCode,
        ),
      );
    } on FormatException catch (exception) {
      return Left<Failure, T>(
        ServerFailure(
          message:
              'Los datos recibidos del servidor no son válidos: '
              '${exception.message}',
        ),
      );
    } catch (exception) {
      return Left<Failure, T>(
        ServerFailure(message: 'Ocurrió un error inesperado: $exception'),
      );
    }
  }
}
