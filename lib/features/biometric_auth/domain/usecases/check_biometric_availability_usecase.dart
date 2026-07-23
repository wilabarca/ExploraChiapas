import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/biometric_availability.dart';
import '../repositories/i_biometric_repository.dart';

@injectable
class CheckBiometricAvailabilityUseCase {
  final IBiometricRepository _repository;
  CheckBiometricAvailabilityUseCase(this._repository);

  Future<Either<Failure, BiometricAvailability>> call() =>
      _repository.checkAvailability();
}
