import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/ubicacion_destino.dart';
import '../repositories/destinos_repository.dart';

@injectable
class GetUbicacionDestinoUseCase {
  final DestinoRepository _repository;

  const GetUbicacionDestinoUseCase(this._repository);

  Future<Either<Failure, UbicacionDestino>> call({required String id}) {
    return _repository.getUbicacionById(id: id);
  }
}
