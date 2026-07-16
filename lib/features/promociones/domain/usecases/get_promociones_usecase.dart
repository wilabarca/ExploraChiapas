import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/promocion.dart';
import '../repositories/promociones_repository.dart';

@injectable
class GetPromocionesUseCase {
  final PromocionesRepository _repository;

  const GetPromocionesUseCase(this._repository);

  Future<Either<Failure, List<PromocionEntity>>> call({
    String? negocioId,
  }) {
    return _repository.getPromociones(negocioId: negocioId);
  }
}