import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/categoria.dart';
import '../repositories/categorias_repository.dart';

@injectable
class GetCategoriasUseCase {
  final CategoriasRepository _repository;

  const GetCategoriasUseCase(this._repository);

  Future<Either<Failure, List<Categoria>>> call({String? scope}) {
    return _repository.getCategorias(scope: scope);
  }
}
