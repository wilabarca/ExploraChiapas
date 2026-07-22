abstract class Failure {
  final String message;
  const Failure({required this.message});
}

class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({required super.message, this.statusCode});
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({
    super.message = 'No autorizado. Por favor inicia sesion.',
  });
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Sin conexion a internet. Verifica tu red.',
  });
}

class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Error al leer datos locales.'});
}

/// Motivo específico de un [BiometricFailure]. Permite a la UI decidir
/// mensaje y acciones (reintentar, cerrar sesión, ir a Ajustes) sin tener
/// que parsear texto libre.
enum BiometricFailureReason {
  /// El dispositivo no tiene sensor de huella / hardware biométrico.
  notAvailable,

  /// Hay sensor, pero el usuario no registró ninguna huella en el sistema.
  notEnrolled,

  /// Demasiados intentos fallidos: bloqueo temporal del sensor.
  lockedOut,

  /// Bloqueo permanente: requiere desbloquear el dispositivo por otra vía.
  permanentlyLockedOut,

  /// El dispositivo no tiene configurado ningún bloqueo de pantalla,
  /// prerrequisito del sistema para poder usar biometría.
  passcodeNotSet,

  /// El usuario canceló el diálogo o la huella no coincidió.
  cancelledOrFailed,

  /// Cualquier otro error no anticipado del sistema biométrico.
  unexpected,
}

class BiometricFailure extends Failure {
  final BiometricFailureReason reason;

  const BiometricFailure({required this.reason, required super.message});
}
