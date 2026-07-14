import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/perfil_entity.dart';
import '../../domain/usecases/get_perfil_usecase.dart';
import '../../domain/usecases/update_perfil_usecase.dart';
import '../../domain/usecases/delete_perfil_usecase.dart';

enum ProfileStatus { idle, loading, success, error }

@lazySingleton
class ProfileProvider extends ChangeNotifier {
  final GetPerfilUseCase _getPerfilUseCase;
  final UpdatePerfilUseCase _updatePerfilUseCase;
  final DeletePerfilUseCase _deletePerfilUseCase;

  ProfileProvider(
    this._getPerfilUseCase,
    this._updatePerfilUseCase,
    this._deletePerfilUseCase,
  );

  ProfileStatus _status = ProfileStatus.idle;
  ProfileStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  PerfilEntity? _perfil;
  PerfilEntity? get perfil => _perfil;

  Future<void> loadPerfil() async {
    _setLoading();

    // ── DEBUG: verificar token ────────────────────────────
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    debugPrint('🔐 Token antes de loadPerfil: ${token ?? "NULL"}');
    debugPrint('🔐 Todas las keys en prefs: ${prefs.getKeys()}');
    // ─────────────────────────────────────────────────────

    final result = await _getPerfilUseCase();
    result.fold(
      (failure) {
        debugPrint('❌ Error loadPerfil: ${failure.message}');
        _setError(failure.message);
      },
      (perfil) {
        debugPrint('✅ Perfil cargado: ${perfil.nombre}');
        _perfil = perfil;
        _setSuccess();
      },
    );
  }

  Future<bool> updatePerfil({String? nombre, String? telefono}) async {
    _setLoading();
    final result = await _updatePerfilUseCase(
      nombre: nombre,
      telefono: telefono,
    );
    return result.fold(
      (failure) {
        _setError(failure.message);
        return false;
      },
      (perfil) {
        _perfil = perfil;
        _setSuccess();
        return true;
      },
    );
  }

  Future<bool> deletePerfil() async {
    _setLoading();
    final result = await _deletePerfilUseCase();
    return result.fold(
      (failure) {
        _setError(failure.message);
        return false;
      },
      (_) {
        _perfil = null;
        _setSuccess();
        return true;
      },
    );
  }

  void _setLoading() {
    _status = ProfileStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setSuccess() {
    _status = ProfileStatus.success;
    notifyListeners();
  }

  void _setError(String message) {
    _status = ProfileStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  void resetStatus() {
    _status = ProfileStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }
}
