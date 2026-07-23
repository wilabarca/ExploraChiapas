import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/propuesta_destino.dart';
import '../repositories/recomendar_repository.dart';

@injectable
class CrearPropuestaUseCase {
  final RecomendarRepository _repository;
  const CrearPropuestaUseCase(this._repository);

  Future<Either<Failure, PropuestaDestino>> call({
    required String name,
    required String description,
    required String categoryId,
    required String locationId,
  }) {
    return _repository.crearPropuesta(
      name: name,
      description: description,
      categoryId: categoryId,
      locationId: locationId,
    );
  }
}
