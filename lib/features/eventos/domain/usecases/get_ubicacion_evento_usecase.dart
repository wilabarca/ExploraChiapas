import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/ubicacion_evento.dart';
import '../repositories/eventos_repository.dart';

@injectable
class GetUbicacionEventoUseCase {
  final EventosRepository _repository;

  const GetUbicacionEventoUseCase(this._repository);

  Future<Either<Failure, UbicacionEvento>> call({required String id}) {
    return _repository.getUbicacionById(id: id);
  }
}
