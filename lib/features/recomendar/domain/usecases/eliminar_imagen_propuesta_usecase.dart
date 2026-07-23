import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../repositories/i_recomendar_repository.dart';

@injectable
class EliminarImagenPropuestaUseCase {
  final IRecomendarRepository _repository;
  EliminarImagenPropuestaUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required String proposalId,
    required String imageId,
  }) {
    return _repository.eliminarImagenPropuesta(
      proposalId: proposalId,
      imageId: imageId,
    );
  }
}
