import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/perfil_entity.dart';
import '../../domain/usecases/get_perfil_usecase.dart';
import '../../domain/usecases/update_perfil_usecase.dart';
import '../../domain/usecases/delete_perfil_usecase.dart';

enum ProfileStatus { idle, loading, success, error }

@injectable
class ProfileProvider extends ChangeNotifier {
  final GetPerfilUseCase    _getPerfilUseCase;
  final UpdatePerfilUseCase _updatePerfilUseCase;
  final DeletePerfilUseCase _deletePerfilUseCase;

  ProfileProvider(
    this._getPerfilUseCase,
    this._updatePerfilUseCase,
    this._deletePerfilUseCase,
  );

  ProfileStatus  _status = ProfileStatus.idle;
  ProfileStatus  get status => _status;

  String?        _errorMessage;
  String?        get errorMessage => _errorMessage;

  PerfilEntity?  _perfil;
  PerfilEntity?  get perfil => _perfil;

  // ── Cargar perfil ─────────────────────────────────────────
  Future<void> loadPerfil() async {
    _setLoading();
    final result = await _getPerfilUseCase();
    result.fold(
      (failure) => _setError(failure.message),
      (perfil)  { _perfil = perfil; _setSuccess(); },
    );
  }

  // ── Actualizar perfil ─────────────────────────────────────
  Future<bool> updatePerfil({String? nombre, String? telefono}) async {
    _setLoading();
    final result = await _updatePerfilUseCase(
      nombre:   nombre,
      telefono: telefono,
    );
    return result.fold(
      (failure) { _setError(failure.message); return false; },
      (perfil)  { _perfil = perfil; _setSuccess(); return true; },
    );
  }

  // ── Eliminar perfil ───────────────────────────────────────
  Future<bool> deletePerfil() async {
    _setLoading();
    final result = await _deletePerfilUseCase();
    return result.fold(
      (failure) { _setError(failure.message); return false; },
      (_)       { _perfil = null; _setSuccess(); return true; },
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