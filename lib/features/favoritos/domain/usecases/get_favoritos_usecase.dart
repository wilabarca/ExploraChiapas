import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/favorito.dart';
import '../repositories/favoritos_repository.dart';

@injectable
class GetFavoritosUseCase {
  final FavoritosRepository _repository;
  GetFavoritosUseCase(this._repository);
  Future<Either<Failure, List<Favorito>>> call() => _repository.getFavoritos();
}
