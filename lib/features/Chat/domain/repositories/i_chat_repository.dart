import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/recomendacion_entity.dart';

abstract class IChatRepository {
  Future<Either<Failure, RecomendacionEntity>> enviarMensaje(
    String texto, {
    List<Map<String, String>> historial = const [],
    double? userLat,
    double? userLng,
    String? nombreUsuario,
    bool esPrimerMensaje = false,
  });
}
