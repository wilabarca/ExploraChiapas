import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/entities/usuario_registro.dart';
import '../../domain/entities/usuario.dart';
import '../../../../core/utils/app_constants.dart';

enum AuthStatus { idle, loading, success, error }

@injectable
class AuthProvider extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final GetProfileUseCase _getProfileUseCase;

  AuthProvider(
    this._loginUseCase,
    this._registerUseCase,
    this._getProfileUseCase,
  );

  AuthStatus _status = AuthStatus.idle;
  AuthStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _token;
  String? get token => _token;

  Usuario? _usuario;
  Usuario? get usuario => _usuario;

  Map<String, dynamic>? _registroData;
  Map<String, dynamic>? get registroData => _registroData;

  // ── Login ─────────────────────────────────────────────────
  Future<bool> login({required String email, required String password}) async {
    _setLoading();

    final loginResult = await _loginUseCase(email: email, password: password);

    final tokenOk = loginResult.fold(
      (failure) {
        _setError(failure.message);
        return false;
      },
      (token) {
        _token = token;
        return true;
      },
    );

    if (!tokenOk) return false;

    final profileResult = await _getProfileUseCase();

    return profileResult.fold(
      (failure) {
        // Si falla el perfil navegamos igual al home
        _setSuccess();
        return true;
      },
      (usuario) async {
        _usuario = usuario;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.userNameKey, usuario.name);
        await prefs.setString(AppConstants.userEmailKey, usuario.email);

        // El tipo ya fue guardado durante el registro.
        // Si no existe (primer login en dispositivo nuevo),
        // lo dejamos vacío y HomePage usará HomeTuristaPage por defecto.
        debugPrint(
          '✅ Login OK — tipo guardado: '
          '${prefs.getString(AppConstants.tipoUsuarioKey)}',
        );

        _setSuccess();
        return true;
      },
    );
  }

  // ── Register ──────────────────────────────────────────────
  Future<bool> register(UsuarioRegistro datos) async {
    _setLoading();

    final result = await _registerUseCase(datos);

    return result.fold(
      (failure) {
        _setError(failure.message);
        return false;
      },
      (data) async {
        _registroData = data;

        // ← guarda el tipo seleccionado por el usuario
        final prefs = await SharedPreferences.getInstance();
        final tipoStr = _tipoToString(datos.tipoUsuario);
        await prefs.setString(AppConstants.tipoUsuarioKey, tipoStr);
        debugPrint('✅ Registro OK — tipo guardado: $tipoStr');

        _setSuccess();
        return true;
      },
    );
  }

  String _tipoToString(TipoUsuario tipo) {
    switch (tipo) {
      case TipoUsuario.turistaNacional:
        return AppConstants.tipoTuristaNacional;
      case TipoUsuario.turistaExtranjero:
        return AppConstants.tipoTuristaExtranjero;
      case TipoUsuario.habitanteLocal:
        return AppConstants.tipoHabitanteLocal;
    }
  }

  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setSuccess() {
    _status = AuthStatus.success;
    notifyListeners();
  }

  void _setError(String message) {
    _status = AuthStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  void resetStatus() {
    _status = AuthStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }
}
