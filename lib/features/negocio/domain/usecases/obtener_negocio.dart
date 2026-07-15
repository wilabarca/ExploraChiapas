import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/negocio.dart';
import '../repositories/negocio_repository.dart';

@injectable
class ObtenerNegocios {
  final NegocioRepository _repository;

  ObtenerNegocios(this._repository);

  Future<Either<Failure, List<Negocio>>> call({
    String? tipoNegocioId,
    String? busqueda,
    bool? soloVerificados,
    double? latitud,
    double? longitud,
  }) {
    return _repository.obtenerNegocios(
      tipoNegocioId: tipoNegocioId,
      busqueda: busqueda,
      soloVerificados: soloVerificados,
      latitud: latitud,
      longitud: longitud,
    );
  }
}