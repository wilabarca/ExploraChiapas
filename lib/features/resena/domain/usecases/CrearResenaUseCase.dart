import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/resena_entity.dart';
import '../repositories/ResenasRepository.dart';

@injectable
class CrearResenaUseCase {
  final ResenasRepository _repository;

  const CrearResenaUseCase(this._repository);

  Future<Either<Failure, Resena>> call({
    required String targetType,
    required String targetId,
    required int rating,
    String? comment,
  }) {
    return _repository.crearResena(
      targetType: targetType,
      targetId: targetId,
      rating: rating,
      comment: comment,
    );
  }
}
