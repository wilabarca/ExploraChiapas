import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/destino.dart';
import '../entities/ubicacion_destino.dart';

abstract class DestinoRepository {
  Future<Either<Failure, List<Destino>>> getDestinos({
    String? categoryId,
    String? locationId,
    String? municipality,
    String? state,
    int limit = 50,
    int offset = 0,
  });

  Future<Either<Failure, Destino>> getDestinoById({required String id});

  Future<Either<Failure, UbicacionDestino>> getUbicacionById({
    required String id,
  });
}
