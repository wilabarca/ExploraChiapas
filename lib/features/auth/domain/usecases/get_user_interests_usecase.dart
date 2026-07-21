import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_interests.dart';
import '../repositories/auth_repository.dart';

@injectable
class GetUserInterestsUseCase {
  final AuthRepository _repository;

  GetUserInterestsUseCase(
    this._repository,
  );

  Future<Either<Failure, UserInterests>>
      call() {
    return _repository.getUserInterests();
  }
}