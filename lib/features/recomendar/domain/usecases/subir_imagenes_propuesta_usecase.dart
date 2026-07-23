import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/propuesta_destino.dart';
import '../repositories/i_recomendar_repository.dart';

@injectable
class SubirImagenesPropuestaUseCase {
  final IRecomendarRepository _repository;
  SubirImagenesPropuestaUseCase(this._repository);

  Future<Either<Failure, PropuestaDestino>> call({
    required String proposalId,
    required List<String> rutasImagenes,
  }) {
    return _repository.subirImagenesPropuesta(
      proposalId: proposalId,
      rutasImagenes: rutasImagenes,
    );
  }
}
