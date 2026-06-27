import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/perfil_entity.dart';
import '../repositories/i_profile_repository.dart';

@injectable
class GetPerfilUseCase {
  final IProfileRepository _repository;
  GetPerfilUseCase(this._repository);

  Future<Either<Failure, PerfilEntity>> call() =>
      _repository.getProfile();
}