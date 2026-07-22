import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/usuario_registro.dart';
import '../../domain/entities/usuario.dart';
import '../../../../core/utils/app_constants.dart';
import '../../domain/usecases/get_user_interests_usecase.dart';
import '../../domain/usecases/update_user_interests_usecase.dart';
import '../../domain/entities/user_interests.dart';
import '../../../../core/services/notifications/onesignal_service.dart';
import '../../../../core/storage/secure_session_storage.dart';

enum AuthStatus { idle, loading, success, error }

@injectable
class AuthProvider extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final GetProfileUseCase _getProfileUseCase;
  final AuthRepository _authRepository;
  final GetUserInterestsUseCase _getUserInterestsUseCase;
  final UpdateUserInterestsUseCase _updateUserInterestsUseCase;
  final SecureSessionStorage _secureStorage;

  AuthProvider(
    this._loginUseCase,
    this._registerUseCase,
    this._getProfileUseCase,
    this._authRepository,
    this._getUserInterestsUseCase,
    this._updateUserInterestsUseCase,
    this._secureStorage,
  );

  AuthStatus _status = AuthStatus.idle;
  AuthStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _token;
  String? get token => _token;

  Usuario? _usuario;
  Usuario? get usuario => _usuario;
  UserInterests? _userInterests;
  UserInterests? get userInterests => _userInterests;

  List<UserInterest> _availableInterests = [];
  List<UserInterest> get availableInterests =>
      List.unmodifiable(_availableInterests);

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

        // ✅ Guardar JWT en almacenamiento seguro (Keystore/Keychain)
        await _secureStorage.setToken(token);
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

        await _secureStorage.setUserName(usuario.name);
        await _secureStorage.setUserEmail(usuario.email);
        await OneSignalService.loginUser(usuario.id);

        debugPrint(
          '✅ Login OK — tipo: ${await _secureStorage.getTipoUsuario()}',
        );

        _setSuccess();
        return true;
      },
    );
  }

  // ── Login con Google ─────────────────────────────────────
  Future<bool> loginWithGoogle({required String idToken}) async {
    _setLoading();

    final loginResult = await _authRepository.loginWithGoogle(idToken: idToken);

    final tokenOk = await loginResult.fold(
      (failure) async {
        _setError(failure.message);
        return false;
      },
      (token) async {
        _token = token;
        await _secureStorage.setToken(token);
        return true;
      },
    );

    if (!tokenOk) return false;

    final profileResult = await _getProfileUseCase();

    return profileResult.fold(
      (failure) {
        debugPrint(
          '⚠️ Perfil no cargado tras login Google: ${failure.message}',
        );
        _setSuccess();
        return true;
      },
      (usuario) async {
        _usuario = usuario;
        await _secureStorage.setUserName(usuario.name);
        await _secureStorage.setUserEmail(usuario.email);
        await OneSignalService.loginUser(usuario.id);
        _setSuccess();
        return true;
      },
    );
  }

  // ── Cargar intereses del usuario ─────────────────────────

  Future<UserInterests?> loadUserInterests() async {
    final result = await _getUserInterestsUseCase();

    return result.fold(
      (failure) {
        _errorMessage = failure.message;

        debugPrint(
          'Error cargando intereses: '
          '${failure.message}',
        );

        notifyListeners();

        return null;
      },
      (userInterests) {
        _userInterests = userInterests;
        _errorMessage = null;

        notifyListeners();

        return userInterests;
      },
    );
  }

  // ── Guardar intereses del usuario ─────────────────────────

  Future<bool> saveUserInterests({required List<String> categoryIds}) async {
    final result = await _updateUserInterestsUseCase(categoryIds: categoryIds);

    return result.fold(
      (failure) {
        _errorMessage = failure.message;

        debugPrint(
          'Error guardando intereses: '
          '${failure.message}',
        );

        notifyListeners();

        return false;
      },
      (userInterests) async {
        _userInterests = userInterests;
        _errorMessage = null;

        /*
       * Se conserva como caché local,
       * pero el backend ya es la
       * fuente real de verdad.
       */
        final prefs = await SharedPreferences.getInstance();

        await prefs.setBool(
          AppConstants.onboardingKey,
          userInterests.onboardingCompleted,
        );

        await prefs.setStringList(
          AppConstants.interesesKey,
          userInterests.interests.map((interest) => interest.name).toList(),
        );

        notifyListeners();

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

        final tipoStr = _tipoToString(datos.tipoUsuario);
        await _secureStorage.setTipoUsuario(tipoStr);

        // Si el registro devuelve token, guardarlo también
        final token = data['token'] as String?;
        if (token != null) {
          _token = token;
          await _secureStorage.setToken(token);
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

  // ── Cerrar sesión ─────────────────────────────────────────
  Future<void> logout() async {
    // Limpia JWT + datos de usuario cacheados (almacenamiento seguro).
    await _secureStorage.clearSession();
    await OneSignalService.logoutUser();

    // Limpiar estado en memoria.
    _token = null;
    _usuario = null;
    _userInterests = null;
    _availableInterests = [];
    _registroData = null;

    _status = AuthStatus.idle;
    _errorMessage = null;

    notifyListeners();
  }

  Future<List<UserInterest>?> loadInterestCategories() async {
    final result = await _authRepository.getInterestCategories();

    return result.fold(
      (failure) {
        _errorMessage = failure.message;

        debugPrint(
          'Error cargando categorías: '
          '${failure.message}',
        );

        notifyListeners();

        return null;
      },
      (categories) {
        _availableInterests = categories;
        _errorMessage = null;

        notifyListeners();

        return categories;
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
