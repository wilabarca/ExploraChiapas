import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/evento.dart';
import '../repositories/eventos_repository.dart';

@injectable
class GetEventoByIdUseCase {
  final EventosRepository _repository;
  GetEventoByIdUseCase(this._repository);
  Future<Either<Failure, Evento>> call(String id) => _repository.getEventoById(id);
}
