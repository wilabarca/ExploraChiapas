import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/favorito.dart';

abstract class FavoritosRepository {
  Future<Either<Failure, List<Favorito>>> getFavoritos();
  Future<Either<Failure, Unit>> addFavorito({required String targetType, required String targetId});
  Future<Either<Failure, Unit>> removeFavorito({required String targetType, required String targetId});
}
