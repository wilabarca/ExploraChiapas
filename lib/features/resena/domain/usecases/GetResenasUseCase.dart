import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/resena_entity.dart';
import '../repositories/ResenasRepository.dart';

@injectable
class GetResenasUseCase {
  final ResenasRepository _repository;

  const GetResenasUseCase(this._repository);

  Future<Either<Failure, List<Resena>>> call({
    required String targetType,
    required String targetId,
  }) {
    return _repository.getResenas(
      targetType: targetType,
      targetId: targetId,
    );
  }
}