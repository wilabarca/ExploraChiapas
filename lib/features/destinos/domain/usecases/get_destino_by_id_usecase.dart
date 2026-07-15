import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/destino.dart';
import '../repositories/destinos_repository.dart';

@injectable
class GetDestinoByIdUseCase {
  final DestinoRepository _repository;

  const GetDestinoByIdUseCase(this._repository);

  Future<Either<Failure, Destino>> call({
    required String id,
  }) {
    return _repository.getDestinoById(id: id);
  }
}