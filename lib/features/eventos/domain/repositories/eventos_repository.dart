import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/evento.dart';

abstract class EventosRepository {
  Future<Either<Failure, List<Evento>>> getEventos({
    bool? proximas,
  });

  Future<Either<Failure, Evento>> getEventoById({
    required String id,
  });
}