import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/error/failures.dart';
import '../entities/favorito.dart';
import '../repositories/favoritos_repository.dart';

@injectable
class GetFavoritosUseCase {
  final FavoritosRepository repository;

  GetFavoritosUseCase(this.repository);

  Future<Either<Failure, List<Favorito>>> call({String? targetType}) async {
    return await repository.getFavoritos(targetType: targetType);
  }
}
