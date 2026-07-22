import 'package:injectable/injectable.dart';
import 'package:local_auth/local_auth.dart';

import '../../domain/entities/biometric_availability.dart';

abstract class IBiometricLocalDatasource {
  Future<BiometricAvailability> checkAvailability();

  /// Lanza el diálogo nativo del sistema. Devuelve `true` si el usuario
  /// verificó su huella correctamente, `false` si canceló o no coincidió.
  /// Ante un error real del sistema biométrico, lanza [LocalAuthException]
  /// (la traduce el repositorio, no esta capa).
  Future<bool> authenticate();
}

@LazySingleton(as: IBiometricLocalDatasource)
class BiometricLocalDatasourceImpl implements IBiometricLocalDatasource {
  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  Future<BiometricAvailability> checkAvailability() async {
    final soportado = await _localAuth.isDeviceSupported();
    if (!soportado) return BiometricAvailability.noSoportado;

    final hayHardware = await _localAuth.canCheckBiometrics;
    if (!hayHardware) return BiometricAvailability.sinHardware;

    final huellasRegistradas = await _localAuth.getAvailableBiometrics();
    if (huellasRegistradas.isEmpty) {
      return BiometricAvailability.sinHuellasRegistradas;
    }

    return BiometricAvailability.disponible;
  }

  @override
  Future<bool> authenticate() {
    return _localAuth.authenticate(
      localizedReason:
          'Coloca tu dedo en el sensor para acceder a ExploraChiapas',
      // Exclusivamente huella/biometría: sin fallback a PIN o patrón.
      biometricOnly: true,
      // Si el sistema suspende la app durante la validación (p. ej. una
      // notificación encima), reintenta al volver en vez de fallar.
      persistAcrossBackgrounding: true,
    );
  }
}
