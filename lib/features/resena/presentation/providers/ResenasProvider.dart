import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/services/user_stats_local_service.dart';
import '../../domain/entities/resena_entity.dart';
import '../../domain/usecases/CrearResenaUseCase.dart';
import '../../domain/usecases/EditarResenaUseCase.dart';
import '../../domain/usecases/EliminarResenaUseCase.dart';
import '../../domain/usecases/GetResenasUseCase.dart';

enum ResenasStatus { idle, loading, success, error }

enum PublicarStatus { idle, loading, success, error }

enum EdicionStatus { idle, loading, success, error }

@injectable
class ResenasProvider extends ChangeNotifier {
  final GetResenasUseCase _getResenas;
  final CrearResenaUseCase _crearResena;
  final EditarResenaUseCase _editarResena;
  final EliminarResenaUseCase _eliminarResena;
  final UserStatsLocalService _statsLocal;

  ResenasProvider(
    this._getResenas,
    this._crearResena,
    this._editarResena,
    this._eliminarResena,
    this._statsLocal,
  );

  int _misResenasCount = 0;
  int get misResenasCount => _misResenasCount;

  Future<void> cargarMisResenasCount() async {
    _misResenasCount = await _statsLocal.obtenerResenasCreadas();
    notifyListeners();
  }

  ResenasStatus _status = ResenasStatus.idle;
  ResenasStatus get status => _status;

  List<Resena> _resenas = const [];
  List<Resena> get resenas => _resenas;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  PublicarStatus _publicarStatus = PublicarStatus.idle;
  PublicarStatus get publicarStatus => _publicarStatus;

  String? _publicarError;
  String? get publicarError => _publicarError;

  /// Promedio de calificación calculado en cliente (la API no lo devuelve).
  double get promedioCalificacion {
    if (_resenas.isEmpty) return 0;
    final suma = _resenas.fold<int>(0, (acc, r) => acc + r.rating);
    return suma / _resenas.length;
  }

  Map<int, double> get desgloseEstrellas {
    final conteo = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    if (_resenas.isEmpty) {
      return conteo.map((k, v) => MapEntry(k, 0.0));
    }
    for (final r in _resenas) {
      conteo[r.rating] = (conteo[r.rating] ?? 0) + 1;
    }
    return conteo.map((k, v) => MapEntry(k, v / _resenas.length));
  }

  Future<void> cargarResenas({
    required String targetType,
    required String targetId,
  }) async {
    _status = ResenasStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _getResenas(
      targetType: targetType,
      targetId: targetId,
    );

    result.fold(
      (failure) {
        _status = ResenasStatus.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (resenas) {
        _resenas = resenas;
        _status = ResenasStatus.success;
        notifyListeners();
      },
    );
  }

  Future<bool> publicarResena({
    required String targetType,
    required String targetId,
    required int rating,
    String? comment,
  }) async {
    _publicarStatus = PublicarStatus.loading;
    _publicarError = null;
    notifyListeners();

    final result = await _crearResena(
      targetType: targetType,
      targetId: targetId,
      rating: rating,
      comment: comment,
    );

    return result.fold(
      (failure) async {
        _publicarStatus = PublicarStatus.error;
        _publicarError = failure.message;
        notifyListeners();
        return false;
      },
      (resena) async {
        _resenas = [resena, ..._resenas];
        _publicarStatus = PublicarStatus.success;
        _misResenasCount = await _statsLocal.incrementarResenasCreadas();
        notifyListeners();
        return true;
      },
    );
  }

  void resetPublicarStatus() {
    _publicarStatus = PublicarStatus.idle;
    _publicarError = null;
    notifyListeners();
  }

  EdicionStatus _edicionStatus = EdicionStatus.idle;
  EdicionStatus get edicionStatus => _edicionStatus;

  String? _edicionError;
  String? get edicionError => _edicionError;

  /// Edita una reseña propia y actualiza la lista en memoria en el
  /// momento (sin recargar), para que el promedio se recalcule al
  /// instante — `promedioCalificacion` ya se deriva de `_resenas`.
  Future<bool> editarResena({
    required String id,
    required int rating,
    String? comment,
  }) async {
    _edicionStatus = EdicionStatus.loading;
    _edicionError = null;
    notifyListeners();

    final result = await _editarResena(
      id: id,
      rating: rating,
      comment: comment,
    );

    return result.fold(
      (failure) {
        _edicionStatus = EdicionStatus.error;
        _edicionError = failure.message;
        notifyListeners();
        return false;
      },
      (resenaActualizada) {
        _resenas = [
          for (final r in _resenas)
            if (r.id == id) resenaActualizada else r,
        ];
        _edicionStatus = EdicionStatus.success;
        notifyListeners();
        return true;
      },
    );
  }

  /// Elimina una reseña propia y la quita de la lista en memoria al
  /// instante — el promedio se recalcula solo.
  Future<bool> eliminarResena(String id) async {
    _edicionStatus = EdicionStatus.loading;
    _edicionError = null;
    notifyListeners();

    final result = await _eliminarResena(id: id);

    return result.fold(
      (failure) {
        _edicionStatus = EdicionStatus.error;
        _edicionError = failure.message;
        notifyListeners();
        return false;
      },
      (_) {
        _resenas = _resenas.where((r) => r.id != id).toList();
        _edicionStatus = EdicionStatus.success;
        notifyListeners();
        return true;
      },
    );
  }

  void resetEdicionStatus() {
    _edicionStatus = EdicionStatus.idle;
    _edicionError = null;
    notifyListeners();
  }
}
