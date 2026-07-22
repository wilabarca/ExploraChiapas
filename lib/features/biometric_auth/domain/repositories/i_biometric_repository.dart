import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/biometric_availability.dart';

abstract class IBiometricRepository {
  /// Verifica si el dispositivo puede usar huella digital ahora mismo.
  Future<Either<Failure, BiometricAvailability>> checkAvailability();

  /// Dispara el diálogo nativo de autenticación biométrica y espera el
  /// resultado. `Right(null)` significa huella verificada correctamente.
  Future<Either<Failure, void>> authenticate();
}
