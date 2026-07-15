import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/negocio.dart';

abstract class NegocioRepository {
  /// Obtiene negocios con filtros opcionales.
  Future<Either<Failure, List<Negocio>>> obtenerNegocios({
    String? tipoNegocioId,
    String? busqueda,
    bool? soloVerificados,
    double? latitud,
    double? longitud,
  });

  Future<Either<Failure, Negocio>> obtenerNegocioPorId(String id);

  Future<Either<Failure, List<Negocio>>> buscarNegocios(String query);
}