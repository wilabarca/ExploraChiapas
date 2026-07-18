import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/promocion.dart';

abstract class PromocionesRepository {
  Future<Either<Failure, List<PromocionEntity>>> getPromociones({
    String? negocioId,
  });
}
