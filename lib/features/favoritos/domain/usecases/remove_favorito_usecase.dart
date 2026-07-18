import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/error/failures.dart';
import '../repositories/favoritos_repository.dart';

@injectable
class RemoveFavoritoUseCase {
  final FavoritosRepository repository;

  RemoveFavoritoUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String targetType,
    required String targetId,
  }) async {
    return await repository.removeFavorito(
      targetType: targetType,
      targetId: targetId,
    );
  }
}
