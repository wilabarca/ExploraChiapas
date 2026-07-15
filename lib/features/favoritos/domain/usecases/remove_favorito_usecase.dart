import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../repositories/favoritos_repository.dart';

@injectable
class RemoveFavoritoUseCase {
  final FavoritosRepository _repository;
  RemoveFavoritoUseCase(this._repository);
  Future<Either<Failure, Unit>> call({required String targetType, required String targetId}) =>
      _repository.removeFavorito(targetType: targetType, targetId: targetId);
}
