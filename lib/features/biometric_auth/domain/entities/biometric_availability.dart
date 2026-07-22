/// Resultado de comprobar si el dispositivo puede usar huella digital.
enum BiometricAvailability {
  /// Hay sensor, está habilitado y tiene al menos una huella registrada.
  disponible,

  /// El dispositivo no soporta autenticación local en absoluto (o no tiene
  /// bloqueo de pantalla configurado, prerrequisito del sistema).
  noSoportado,

  /// El dispositivo no cuenta con sensor de huella / hardware biométrico.
  sinHardware,

  /// Hay sensor, pero el usuario no registró ninguna huella todavía.
  sinHuellasRegistradas,
}

extension BiometricAvailabilityX on BiometricAvailability {
  bool get esUtilizable => this == BiometricAvailability.disponible;
}
