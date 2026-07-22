import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/ubicacion_sugerida.dart';

abstract class IRecomendarRepository {
  /// POST /v1/api/locations (requiere Authorization: Bearer TOKEN).
  /// El backend crea la ubicación con estado de revisión "pendiente";
  /// solo será visible en la app una vez que un administrador la apruebe.
  Future<Either<Failure, UbicacionSugerida>> sugerirLugar({
    required double latitude,
    required double longitude,
    String? address,
  });
}
