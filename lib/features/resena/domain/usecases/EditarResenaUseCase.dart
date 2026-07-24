import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/resena_entity.dart';
import '../repositories/ResenasRepository.dart';

@injectable
class EditarResenaUseCase {
  final ResenasRepository _repository;

  const EditarResenaUseCase(this._repository);

  Future<Either<Failure, Resena>> call({
    required String id,
    required int rating,
    String? comment,
  }) {
    return _repository.editarResena(id: id, rating: rating, comment: comment);
  }
}
