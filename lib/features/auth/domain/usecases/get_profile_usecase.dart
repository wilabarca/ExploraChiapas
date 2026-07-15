import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/usuario.dart';
import '../repostories/auth_repository.dart';

@injectable
class GetProfileUseCase {
  final AuthRepository _repository;

  GetProfileUseCase(this._repository);

  Future<Either<Failure, Usuario>> call() {
    return _repository.getProfile();
  }
}