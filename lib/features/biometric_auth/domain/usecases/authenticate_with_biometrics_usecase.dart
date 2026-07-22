import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../repositories/i_biometric_repository.dart';

@injectable
class AuthenticateWithBiometricsUseCase {
  final IBiometricRepository _repository;
  AuthenticateWithBiometricsUseCase(this._repository);

  Future<Either<Failure, void>> call() => _repository.authenticate();
}
