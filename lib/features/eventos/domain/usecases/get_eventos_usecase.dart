import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/evento.dart';
import '../repositories/eventos_repository.dart';

@injectable
class GetEventosUseCase {
  final EventosRepository _repository;

  const GetEventosUseCase(this._repository);

  Future<Either<Failure, List<Evento>>> call({
    bool? proximas,
  }) {
    return _repository.getEventos(
      proximas: proximas,
    );
  }
}