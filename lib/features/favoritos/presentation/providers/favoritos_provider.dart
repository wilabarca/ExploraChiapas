import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/favorito.dart';
import '../../domain/usecases/add_favorito_usecase.dart';
import '../../domain/usecases/get_favoritos_usecase.dart';
import '../../domain/usecases/remove_favorito_usecase.dart';

enum FavoritosStatus { idle, loading, success, error }

@injectable
class FavoritosProvider extends ChangeNotifier {
  final GetFavoritosUseCase _getFavoritos;
  final AddFavoritoUseCase _addFavorito;
  final RemoveFavoritoUseCase _removeFavorito;

  FavoritosProvider(this._getFavoritos, this._addFavorito, this._removeFavorito);

  FavoritosStatus _status = FavoritosStatus.idle;
  FavoritosStatus get status => _status;

  List<Favorito> _favoritos = const [];
  List<Favorito> get favoritos => _favoritos;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool contiene(String targetType, String targetId) => _favoritos.any(
        (item) => item.targetType == targetType && item.targetId == targetId,
      );

  Future<bool> cargarFavoritos() async {
    _setLoading();
    final result = await _getFavoritos();
    return result.fold(
      (failure) {
        _setError(failure.message);
        return false;
      },
      (items) {
        _favoritos = items;
        _setSuccess();
        return true;
      },
    );
  }

  Future<bool> alternar({required String targetType, required String targetId}) async {
    _setLoading();
    final yaExiste = contiene(targetType, targetId);
    final result = yaExiste
        ? await _removeFavorito(targetType: targetType, targetId: targetId)
        : await _addFavorito(targetType: targetType, targetId: targetId);

    return result.fold(
      (failure) {
        _setError(failure.message);
        return false;
      },
      (_) async {
        return cargarFavoritos();
      },
    );
  }

  void _setLoading() {
    _status = FavoritosStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setSuccess() {
    _status = FavoritosStatus.success;
    notifyListeners();
  }

  void _setError(String message) {
    _status = FavoritosStatus.error;
    _errorMessage = message;
    notifyListeners();
  }
}
