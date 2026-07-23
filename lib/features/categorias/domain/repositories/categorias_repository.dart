import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/categoria.dart';

abstract class CategoriasRepository {
  Future<Either<Failure, List<Categoria>>> getCategorias({String? scope});
}
