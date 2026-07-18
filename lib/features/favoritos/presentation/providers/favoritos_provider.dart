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

  FavoritosProvider(
    this._getFavoritos,
    this._addFavorito,
    this._removeFavorito,
  );

  FavoritosStatus _status = FavoritosStatus.idle;
  FavoritosStatus get status => _status;

  List<Favorito> _favoritos = const [];
  List<Favorito> get favoritos => _favoritos;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final Set<String> _procesando = {};
  bool estaProcesando(String targetType, String targetId) =>
      _procesando.contains('$targetType:$targetId');

  bool esFavorito(String targetType, String targetId) {
    return _favoritos.any(
      (f) => f.targetType == targetType && f.targetId == targetId,
    );
  }

  List<Favorito> get destinosFavoritos => _favoritos
      .where((f) => f.targetType == FavoritoTargetType.destination)
      .toList();

  List<Favorito> get negociosFavoritos => _favoritos
      .where((f) => f.targetType == FavoritoTargetType.business)
      .toList();

  Future<void> cargarFavoritos({String? targetType}) async {
    _status = FavoritosStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _getFavoritos(targetType: targetType);

    result.fold(
      (failure) {
        _status = FavoritosStatus.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (favoritos) {
        _favoritos = favoritos;
        _status = FavoritosStatus.success;
        notifyListeners();
      },
    );
  }

  Future<bool> agregarFavorito({
    required String targetType,
    required String targetId,
  }) async {
    final key = '$targetType:$targetId';
    _procesando.add(key);
    notifyListeners();

    final result = await _addFavorito(
      targetType: targetType,
      targetId: targetId,
    );

    _procesando.remove(key);

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (favorito) {
        _favoritos = [favorito, ..._favoritos];
        _errorMessage = null;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> quitarFavorito({
    required String targetType,
    required String targetId,
  }) async {
    final key = '$targetType:$targetId';
    _procesando.add(key);
    notifyListeners();

    final result = await _removeFavorito(
      targetType: targetType,
      targetId: targetId,
    );

    _procesando.remove(key);

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (_) {
        _favoritos = _favoritos
            .where(
              (f) => !(f.targetType == targetType && f.targetId == targetId),
            )
            .toList();
        _errorMessage = null;
        notifyListeners();
        return true;
      },
    );
  }

  Future<void> toggleFavorito({
    required String targetType,
    required String targetId,
  }) async {
    if (esFavorito(targetType, targetId)) {
      await quitarFavorito(targetType: targetType, targetId: targetId);
    } else {
      await agregarFavorito(targetType: targetType, targetId: targetId);
    }
  }

  void limpiar() {
    _favoritos = const [];
    _status = FavoritosStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }
}
