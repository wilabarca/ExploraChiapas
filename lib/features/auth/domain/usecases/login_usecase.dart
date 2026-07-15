
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repostories/auth_repository.dart';

@injectable
class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<Either<Failure, String>> call({
    required String email,
    required String password,
  }) {
    return _repository.login(email: email, password: password);
  }
}