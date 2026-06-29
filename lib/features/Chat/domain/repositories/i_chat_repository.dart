import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/recomendacion_entity.dart';

abstract class IChatRepository {
  Future<Either<Failure, RecomendacionEntity>> enviarMensaje(String texto);
}
