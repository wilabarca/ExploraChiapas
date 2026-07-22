import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/ubicacion_sugerida.dart';
import '../repositories/i_recomendar_repository.dart';

@injectable
class SugerirLugarUseCase {
  final IRecomendarRepository _repository;
  SugerirLugarUseCase(this._repository);

  Future<Either<Failure, UbicacionSugerida>> call({
    required double latitude,
    required double longitude,
    String? address,
  }) {
    return _repository.sugerirLugar(
      latitude: latitude,
      longitude: longitude,
      address: address,
    );
  }
}
