import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/categoria.dart';
import '../repositories/recomendar_repository.dart';

@injectable
class GetCategoriasUseCase {
  final RecomendarRepository _repository;
  const GetCategoriasUseCase(this._repository);

  Future<Either<Failure, List<Categoria>>> call() {
    return _repository.getCategorias();
  }
}
