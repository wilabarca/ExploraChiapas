import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../core/error/failures.dart';
import '../../../../domain/entities/negocio.dart';
import '../../../../domain/repositories/negocio_repository.dart';

@injectable
class BuscarNegocios {
  final NegocioRepository _repository;

  BuscarNegocios(this._repository);

  Future<Either<Failure, List<Negocio>>> call(String query) {
    return _repository.buscarNegocios(query);
  }
}
