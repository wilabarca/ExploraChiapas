import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_interests.dart';
import '../repositories/auth_repository.dart';

@injectable
class UpdateUserInterestsUseCase {
  final AuthRepository _repository;

  UpdateUserInterestsUseCase(
    this._repository,
  );

  Future<Either<Failure, UserInterests>>
      call({
    required List<String> categoryIds,
  }) {
    return _repository.updateUserInterests(
      categoryIds: categoryIds,
    );
  }
}