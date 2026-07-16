import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/resena_entity.dart';
import '../../domain/usecases/CrearResenaUseCase.dart';
import '../../domain/usecases/GetResenasUseCase.dart';

enum ResenasStatus { idle, loading, success, error }

enum PublicarStatus { idle, loading, success, error }

@injectable
class ResenasProvider extends ChangeNotifier {
  final GetResenasUseCase _getResenas;
  final CrearResenaUseCase _crearResena;

  ResenasProvider(this._getResenas, this._crearResena);

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
      (failure) {
        _publicarStatus = PublicarStatus.error;
        _publicarError = failure.message;
        notifyListeners();
        return false;
      },
      (resena) {
        _resenas = [resena, ..._resenas];
        _publicarStatus = PublicarStatus.success;
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
}
