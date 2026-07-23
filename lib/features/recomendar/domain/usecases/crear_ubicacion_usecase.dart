import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/ubicacion_propuesta.dart';
import '../repositories/recomendar_repository.dart';

@injectable
class CrearUbicacionUseCase {
  final RecomendarRepository _repository;
  const CrearUbicacionUseCase(this._repository);

  Future<Either<Failure, String>> call(UbicacionPropuesta ubicacion) {
    return _repository.crearUbicacion(ubicacion);
  }
}
