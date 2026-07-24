import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../repositories/ResenasRepository.dart';

@injectable
class EliminarResenaUseCase {
  final ResenasRepository _repository;

  const EliminarResenaUseCase(this._repository);

  Future<Either<Failure, void>> call({required String id}) {
    return _repository.eliminarResena(id: id);
  }
}
