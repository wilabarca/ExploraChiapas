import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/evento.dart';
import '../repositories/eventos_repository.dart';

@injectable
class GetEventosUseCase {
  final EventosRepository _repository;
  GetEventosUseCase(this._repository);
  Future<Either<Failure, List<Evento>>> call() => _repository.getEventos();
}
