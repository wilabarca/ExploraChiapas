import 'package:dartz/dartz.dart';

import '../../../../../core/error/failures.dart';
import '../entities/favorito.dart';

abstract class FavoritosRepository {
  Future<Either<Failure, List<Favorito>>> getFavoritos({String? targetType});

  Future<Either<Failure, Favorito>> addFavorito({
    required String targetType,
    required String targetId,
  });

  Future<Either<Failure, void>> removeFavorito({
    required String targetType,
    required String targetId,
  });

  Future<Either<Failure, bool>> isFavorito({
    required String targetType,
    required String targetId,
  });
}
