import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../repositories/favoritos_repository.dart';

@injectable
class AddFavoritoUseCase {
  final FavoritosRepository _repository;
  AddFavoritoUseCase(this._repository);
  Future<Either<Failure, Unit>> call({required String targetType, required String targetId}) =>
      _repository.addFavorito(targetType: targetType, targetId: targetId);
}
