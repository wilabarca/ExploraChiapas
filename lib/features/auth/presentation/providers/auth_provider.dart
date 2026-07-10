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

  // ── Datos temporales del registro para auto-login ──
  Map<String, dynamic>? _registroData;
  Map<String, dynamic>? get registroData => _registroData;

  // ── Login ─────────────────────────────────────────────────
  Future<bool> login({required String email, required String password}) async {
    _setLoading();

    final loginResult = await _loginUseCase(email: email, password: password);

    final tokenOk = await loginResult.fold(
      (failure) async {
        _setError(failure.message);
        return false;
      },
      (token) async {
        _token = token;

        // ✅ Guardar JWT en SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.jwtTokenKey, token);
        debugPrint('✅ JWT guardado: ${token.substring(0, 30)}...');

        return true;
      },
    );

    if (!tokenOk) return false;

    final profileResult = await _getProfileUseCase();

    return profileResult.fold(
      (failure) {
        debugPrint('⚠️ Perfil no cargado tras login: ${failure.message}');
        _setSuccess();
        return true;
      },
      (usuario) async {
        _usuario = usuario;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.userNameKey, usuario.name);
        await prefs.setString(AppConstants.userEmailKey, usuario.email);

        debugPrint(
          '✅ Login OK — tipo: ${prefs.getString(AppConstants.tipoUsuarioKey)}',
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
        // ✅ Guardar email y password TEMPORALMENTE para auto-login
        //    (se limpian después en InterestsPage)
        _registroData = {
          ...data,
          'email': datos.correo, // <-- email para auto-login
          'password': datos.contrasena, // <-- password para auto-login
        };

        final prefs = await SharedPreferences.getInstance();
        final tipoStr = _tipoToString(datos.tipoUsuario);
        await prefs.setString(AppConstants.tipoUsuarioKey, tipoStr);

        // Si el registro devuelve token, guardarlo también
        final token = data['token'] as String?;
        if (token != null) {
          _token = token;
          await prefs.setString(AppConstants.jwtTokenKey, token);
          debugPrint(
            '✅ JWT guardado tras registro: ${token.substring(0, 30)}...',
          );
        } else {
          debugPrint('⚠️ Registro sin token — se requiere login manual');
        }

        debugPrint('✅ Registro OK — tipo: $tipoStr');
        _setSuccess();
        return true;
      },
    );
  }

  // ── Limpiar datos temporales del registro ──
  void clearRegistroData() {
    _registroData = null;
    notifyListeners();
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
