import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/error/failures.dart';
import '../entities/categoria.dart';
import '../entities/propuesta_destino.dart';
import '../entities/ubicacion_propuesta.dart';

abstract class RecomendarRepository {
  Future<Either<Failure, List<Categoria>>> getCategorias();

  Future<Either<Failure, String>> crearUbicacion(
    UbicacionPropuesta ubicacion,
  );

  Future<Either<Failure, PropuestaDestino>> crearPropuesta({
    required String name,
    required String description,
    required String categoryId,
    required String locationId,
  });

  Future<Either<Failure, void>> subirImagenes({
    required String proposalId,
    required List<XFile> imagenes,
  });

  Future<Either<Failure, List<PropuestaDestino>>> getMisPropuestas();
}
