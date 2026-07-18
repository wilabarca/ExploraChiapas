import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/error/failures.dart';
import '../entities/favorito.dart';
import '../repositories/favoritos_repository.dart';

@injectable
class AddFavoritoUseCase {
  final FavoritosRepository repository;

  AddFavoritoUseCase(this.repository);

  Future<Either<Failure, Favorito>> call({
    required String targetType,
    required String targetId,
  }) async {
    return await repository.addFavorito(
      targetType: targetType,
      targetId: targetId,
    );
  }
}
