import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/evento.dart';

abstract class EventosRepository {
  Future<Either<Failure, List<Evento>>> getEventos();
  Future<Either<Failure, Evento>> getEventoById(String id);
}
