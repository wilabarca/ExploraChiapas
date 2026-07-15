import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/destino.dart';
import '../repositories/destinos_repository.dart';

@injectable
class ListDestinosUseCase {
  final DestinoRepository _repository;

  const ListDestinosUseCase(this._repository);

  Future<Either<Failure, List<Destino>>> call({
    String? categoryId,
    String? locationId,
    String? municipality,
    String? state,
    int limit = 50,
    int offset = 0,
  }) {
    return _repository.getDestinos(
      categoryId: categoryId,
      locationId: locationId,
      municipality: municipality,
      state: state,
      limit: limit,
      offset: offset,
    );
  }
}