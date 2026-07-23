import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../utils/app_constants.dart';

/// Único punto de acceso al JWT y a los datos de sesión del usuario
/// (nombre, correo, tipo de usuario). Antes vivían en `SharedPreferences`
/// en texto plano; ahora usan `flutter_secure_storage`, respaldado por el
/// Keystore en Android y el Keychain en iOS.
///
/// El resto de la app (preferencias de idioma/tema/moneda, bandera de
/// onboarding, permiso de ubicación concedido, etc.) sigue en
/// `SharedPreferences` sin cambios: esos valores no son sensibles y no
/// forman parte de este hallazgo de seguridad.
@lazySingleton
class SecureSessionStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<String?> getToken() => _storage.read(key: AppConstants.jwtTokenKey);

  Future<void> setToken(String token) =>
      _storage.write(key: AppConstants.jwtTokenKey, value: token);

  Future<String?> getUserName() => _storage.read(key: AppConstants.userNameKey);

  Future<void> setUserName(String value) =>
      _storage.write(key: AppConstants.userNameKey, value: value);

  Future<String?> getUserEmail() =>
      _storage.read(key: AppConstants.userEmailKey);

  Future<void> setUserEmail(String value) =>
      _storage.write(key: AppConstants.userEmailKey, value: value);

  Future<String?> getTipoUsuario() =>
      _storage.read(key: AppConstants.tipoUsuarioKey);

  Future<void> setTipoUsuario(String value) =>
      _storage.write(key: AppConstants.tipoUsuarioKey, value: value);

  /// Limpia por completo la sesión guardada (token + datos de usuario).
  /// Se usa al cerrar sesión y al eliminar la cuenta.
  Future<void> clearSession() async {
    await _storage.delete(key: AppConstants.jwtTokenKey);
    await _storage.delete(key: AppConstants.userNameKey);
    await _storage.delete(key: AppConstants.userEmailKey);
    await _storage.delete(key: AppConstants.tipoUsuarioKey);
  }
}
