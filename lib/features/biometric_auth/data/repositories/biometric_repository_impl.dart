import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:local_auth/local_auth.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/biometric_availability.dart';
import '../../domain/repositories/i_biometric_repository.dart';
import '../datasource/biometric_local_datasource.dart';

@Injectable(as: IBiometricRepository)
class BiometricRepositoryImpl implements IBiometricRepository {
  final IBiometricLocalDatasource _datasource;
  BiometricRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, BiometricAvailability>> checkAvailability() async {
    try {
      final disponibilidad = await _datasource.checkAvailability();
      return Right(disponibilidad);
    } on LocalAuthException catch (e) {
      // No debería fallar como excepción (son solo consultas), pero por si
      // el sistema operativo devuelve un error inesperado, se informa como
      // "no soportado" en vez de propagar el error hacia la UI.
      return Left(
        BiometricFailure(
          reason: BiometricFailureReason.unexpected,
          message:
              e.description ?? 'No fue posible verificar el sensor de huella.',
        ),
      );
    } catch (_) {
      return const Left(
        BiometricFailure(
          reason: BiometricFailureReason.unexpected,
          message: 'No fue posible verificar el sensor de huella.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> authenticate() async {
    try {
      final verificado = await _datasource.authenticate();
      if (verificado) return const Right(null);

      return const Left(
        BiometricFailure(
          reason: BiometricFailureReason.cancelledOrFailed,
          message: 'No se pudo verificar tu huella. Inténtalo de nuevo.',
        ),
      );
    } on LocalAuthException catch (e) {
      return Left(_mapExcepcion(e));
    } catch (_) {
      return const Left(
        BiometricFailure(
          reason: BiometricFailureReason.unexpected,
          message: 'Ocurrió un error inesperado al verificar tu huella.',
        ),
      );
    }
  }

  BiometricFailure _mapExcepcion(LocalAuthException e) {
    switch (e.code) {
      case LocalAuthExceptionCode.noBiometricHardware:
      case LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable:
        return const BiometricFailure(
          reason: BiometricFailureReason.notAvailable,
          message: 'Tu dispositivo no tiene un sensor de huella disponible.',
        );
      case LocalAuthExceptionCode.noBiometricsEnrolled:
        return const BiometricFailure(
          reason: BiometricFailureReason.notEnrolled,
          message: 'No tienes huellas registradas en este dispositivo.',
        );
      case LocalAuthExceptionCode.noCredentialsSet:
        return const BiometricFailure(
          reason: BiometricFailureReason.passcodeNotSet,
          message:
              'Configura un bloqueo de pantalla en tu dispositivo para poder usar la huella.',
        );
      case LocalAuthExceptionCode.temporaryLockout:
        return const BiometricFailure(
          reason: BiometricFailureReason.lockedOut,
          message:
              'Demasiados intentos fallidos. Espera un momento e inténtalo de nuevo.',
        );
      case LocalAuthExceptionCode.biometricLockout:
        return const BiometricFailure(
          reason: BiometricFailureReason.permanentlyLockedOut,
          message:
              'El sensor de huella fue bloqueado por seguridad. Desbloquea tu dispositivo para restablecerlo.',
        );
      case LocalAuthExceptionCode.userCanceled:
      case LocalAuthExceptionCode.systemCanceled:
      case LocalAuthExceptionCode.timeout:
        return const BiometricFailure(
          reason: BiometricFailureReason.cancelledOrFailed,
          message: 'No se pudo verificar tu huella. Inténtalo de nuevo.',
        );
      default:
        // Cubre authInProgress, uiUnavailable, userRequestedFallback,
        // deviceError, unknownError y cualquier código futuro: el propio
        // paquete advierte que este enum puede crecer sin considerarse
        // breaking change, así que se evita un `switch` exhaustivo.
        return BiometricFailure(
          reason: BiometricFailureReason.unexpected,
          message:
              e.description ??
              'Ocurrió un error inesperado al verificar tu huella.',
        );
    }
  }
}
