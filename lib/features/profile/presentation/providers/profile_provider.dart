import 'dart:io';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/perfil_entity.dart';
import '../../domain/usecases/get_perfil_usecase.dart';
import '../../domain/usecases/update_perfil_usecase.dart';
import '../../domain/usecases/delete_perfil_usecase.dart';
import '../../domain/usecases/upload_foto_perfil_usecase.dart';

enum ProfileStatus { idle, loading, success, error }

@lazySingleton
class ProfileProvider extends ChangeNotifier {
  final GetPerfilUseCase _getPerfilUseCase;
  final UpdatePerfilUseCase _updatePerfilUseCase;
  final DeletePerfilUseCase _deletePerfilUseCase;
  final UploadFotoPerfilUseCase _uploadFotoPerfilUseCase;

  ProfileProvider(
    this._getPerfilUseCase,
    this._updatePerfilUseCase,
    this._deletePerfilUseCase,
    this._uploadFotoPerfilUseCase,
  );

  ProfileStatus _status = ProfileStatus.idle;
  ProfileStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Código HTTP del último error (cuando aplica). Permite a la UI dar un
  // trato distinto a casos puntuales, p. ej. 404 al eliminar una cuenta
  // que ya no existe en el backend.
  int? _errorStatusCode;
  int? get errorStatusCode => _errorStatusCode;

  PerfilEntity? _perfil;
  PerfilEntity? get perfil => _perfil;

  // Estado separado para no bloquear el resto de la pantalla mientras
  // se sube la imagen (independiente de 'status').
  bool _subiendoFoto = false;
  bool get subiendoFoto => _subiendoFoto;

  Future<void> loadPerfil() async {
    _setLoading();
    final result = await _getPerfilUseCase();
    result.fold((failure) => _setError(failure.message), (perfil) {
      _perfil = perfil;
      _setSuccess();
    });
  }

  Future<bool> updatePerfil({
    String? nombre,
    String? telefono,
    String? fotoPerfilUrl,
  }) async {
    _setLoading();
    final result = await _updatePerfilUseCase(
      nombre: nombre,
      telefono: telefono,
      fotoPerfilUrl: fotoPerfilUrl,
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

  Future<bool> subirFotoPerfil(File file) async {
    _subiendoFoto = true;
    _errorMessage = null;
    notifyListeners();

    final uploadResult = await _uploadFotoPerfilUseCase(file);

    return uploadResult.fold(
      (failure) {
        _subiendoFoto = false;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (_) async {
        // El endpoint de upload ya persiste imagen_perfil_url en PostgreSQL.
        // Recargamos el perfil desde la API para que la BD sea la fuente de verdad.
        await loadPerfil();
        _subiendoFoto = false;
        final success =
            _status == ProfileStatus.success &&
            _perfil != null &&
            _perfil!.ImgUrl.isNotEmpty;
        notifyListeners();
        return success;
      },
    );
  }

  Future<bool> deletePerfil() async {
    _setLoading();
    final result = await _deletePerfilUseCase();
    return result.fold(
      (failure) {
        final statusCode = failure is ServerFailure ? failure.statusCode : null;
        _setError(failure.message, statusCode: statusCode);
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
    _errorStatusCode = null;
    notifyListeners();
  }

  void _setSuccess() {
    _status = ProfileStatus.success;
    _errorStatusCode = null;
    notifyListeners();
  }

  void _setError(String message, {int? statusCode}) {
    _status = ProfileStatus.error;
    _errorMessage = message;
    _errorStatusCode = statusCode;
    notifyListeners();
  }

  void resetStatus() {
    _status = ProfileStatus.idle;
    _errorMessage = null;
    _errorStatusCode = null;
    notifyListeners();
  }
}
