import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/propuesta_destino.dart';
import '../repositories/recomendar_repository.dart';

@injectable
class GetMisPropuestasUseCase {
  final RecomendarRepository _repository;
  const GetMisPropuestasUseCase(this._repository);

  Future<Either<Failure, List<PropuestaDestino>>> call() {
    return _repository.getMisPropuestas();
  }
}
