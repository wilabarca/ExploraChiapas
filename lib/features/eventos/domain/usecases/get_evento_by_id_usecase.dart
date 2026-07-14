import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/evento.dart';
import '../repositories/eventos_repository.dart';

@injectable
class GetEventoByIdUseCase {
  final EventosRepository _repository;

  const GetEventoByIdUseCase(this._repository);

  Future<Either<Failure, Evento>> call({
    required String id,
  }) {
    return _repository.getEventoById(
      id: id,
    );
  }
}