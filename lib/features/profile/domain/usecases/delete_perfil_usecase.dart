import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/i_profile_repository.dart';

@injectable
class DeletePerfilUseCase {
  final IProfileRepository _repository;
  DeletePerfilUseCase(this._repository);

  Future<Either<Failure, void>> call() =>
      _repository.deleteProfile();
}