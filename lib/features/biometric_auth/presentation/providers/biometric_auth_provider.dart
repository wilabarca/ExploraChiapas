import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/biometric_availability.dart';
import '../../domain/usecases/authenticate_with_biometrics_usecase.dart';
import '../../domain/usecases/check_biometric_availability_usecase.dart';

enum BiometricGateStatus {
  idle,
  verificandoDisponibilidad,
  autenticando,
  exito,
  error,
}

@injectable
class BiometricAuthProvider extends ChangeNotifier {
  final CheckBiometricAvailabilityUseCase _checkAvailability;
  final AuthenticateWithBiometricsUseCase _authenticate;

  BiometricAuthProvider(this._checkAvailability, this._authenticate);

  BiometricGateStatus _status = BiometricGateStatus.idle;
  BiometricGateStatus get status => _status;

  BiometricAvailability? _disponibilidad;
  BiometricAvailability? get disponibilidad => _disponibilidad;

  BiometricFailureReason? _errorReason;
  BiometricFailureReason? get errorReason => _errorReason;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Reintentos fallidos consecutivos durante esta sesión de pantalla.
  /// Solo es informativo para la UI (no bloquea nada por sí mismo: el
  /// propio sensor ya aplica su bloqueo temporal/permanente).
  int _intentosFallidos = 0;
  int get intentosFallidos => _intentosFallidos;

  Future<BiometricAvailability> verificarDisponibilidad() async {
    _status = BiometricGateStatus.verificandoDisponibilidad;
    notifyListeners();

    final result = await _checkAvailability();

    return result.fold(
      (failure) {
        _disponibilidad = BiometricAvailability.noSoportado;
        _status = BiometricGateStatus.idle;
        notifyListeners();
        return BiometricAvailability.noSoportado;
      },
      (availability) {
        _disponibilidad = availability;
        _status = BiometricGateStatus.idle;
        notifyListeners();
        return availability;
      },
    );
  }

  Future<bool> autenticar() async {
    _status = BiometricGateStatus.autenticando;
    _errorMessage = null;
    _errorReason = null;
    notifyListeners();

    final result = await _authenticate();

    return result.fold(
      (failure) {
        _intentosFallidos++;
        _status = BiometricGateStatus.error;
        _errorMessage = failure.message;
        _errorReason = failure is BiometricFailure
            ? failure.reason
            : BiometricFailureReason.unexpected;
        notifyListeners();
        return false;
      },
      (_) {
        _intentosFallidos = 0;
        _status = BiometricGateStatus.exito;
        notifyListeners();
        return true;
      },
    );
  }

  void reset() {
    _status = BiometricGateStatus.idle;
    _errorMessage = null;
    _errorReason = null;
    _intentosFallidos = 0;
    notifyListeners();
  }
}
