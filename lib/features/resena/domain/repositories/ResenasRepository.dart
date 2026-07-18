import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/resena_entity.dart';

abstract class ResenasRepository {
  /// GET /v1/api/reviews?targetType=...&targetId=...  (no requiere token)
  Future<Either<Failure, List<Resena>>> getResenas({
    required String targetType,
    required String targetId,
  });

  /// POST /v1/api/reviews  (requiere Authorization: Bearer TOKEN)
  Future<Either<Failure, Resena>> crearResena({
    required String targetType,
    required String targetId,
    required int rating,
    String? comment,
  });
}
