import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/evento.dart';
import '../../domain/repositories/eventos_repository.dart';
import '../datasource/eventos_remote_datasource.dart';

@LazySingleton(as: EventosRepository)
class EventosRepositoryImpl implements EventosRepository {
  final EventosRemoteDataSource _dataSource;

  EventosRepositoryImpl(this._dataSource);


  @override
  Future<Either<Failure, List<Evento>>> getEventos() async {
    try {
      return Right(await _dataSource.getEventos());
    } catch (error) {
      return Left(_failure(error));
    }
  }

  @override
  Future<Either<Failure, Evento>> getEventoById(String id) async {
    try {
      return Right(await _dataSource.getEventoById(id));
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
