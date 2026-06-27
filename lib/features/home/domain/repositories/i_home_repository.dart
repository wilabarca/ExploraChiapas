import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/destino_entity.dart';

abstract class IHomeRepository {
  Future<Either<Failure, List<DestinoEntity>>> getDestinos({String? tipo});
}