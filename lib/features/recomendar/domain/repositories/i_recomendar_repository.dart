import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/propuesta_destino.dart';
import '../entities/ubicacion_sugerida.dart';

abstract class IRecomendarRepository {
  /// POST /v1/api/locations (requiere Authorization: Bearer TOKEN).
  /// El backend crea la ubicación con estado de revisión "pendiente";
  /// solo será visible en la app una vez que un administrador la apruebe.
  Future<Either<Failure, UbicacionSugerida>> sugerirLugar({
    required double latitude,
    required double longitude,
    String? address,
    String? municipality,
    String? state,
    String? mapProvider,
  });

  /// POST /v1/api/destination-proposals.
  Future<Either<Failure, PropuestaDestino>> crearPropuesta({
    required String name,
    required String description,
    required String categoryId,
    required String locationId,
  });

  /// POST /v1/api/destination-proposals/{id}/images (1 a 5 fotos).
  Future<Either<Failure, PropuestaDestino>> subirImagenesPropuesta({
    required String proposalId,
    required List<String> rutasImagenes,
  });

  /// GET /v1/api/destination-proposals/mine.
  Future<Either<Failure, List<PropuestaDestino>>> obtenerMisPropuestas();

  /// DELETE /v1/api/destination-proposals/{id}/images/{imageId}.
  Future<Either<Failure, void>> eliminarImagenPropuesta({
    required String proposalId,
    required String imageId,
  });
}
