import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/negocio.dart';
import '../repositories/negocio_repository.dart';

@injectable
class ObtenerNegocioPorId {
  final NegocioRepository _repository;

  ObtenerNegocioPorId(this._repository);

  Future<Either<Failure, Negocio>> call(String id) {
    return _repository.obtenerNegocioPorId(id);
  }
}