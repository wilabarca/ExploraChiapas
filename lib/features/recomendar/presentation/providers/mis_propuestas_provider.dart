import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/propuesta_destino.dart';
import '../../domain/usecases/get_mis_propuestas_usecase.dart';

enum MisPropuestasStatus { idle, loading, success, error }

@injectable
class MisPropuestasProvider extends ChangeNotifier {
  final GetMisPropuestasUseCase _getMisPropuestas;

  MisPropuestasProvider(this._getMisPropuestas);

  MisPropuestasStatus _status = MisPropuestasStatus.idle;
  MisPropuestasStatus get status => _status;

  List<PropuestaDestino> _propuestas = [];
  List<PropuestaDestino> get propuestas => _propuestas;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> cargar() async {
    _status = MisPropuestasStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _getMisPropuestas();
    result.fold(
      (failure) {
        _status = MisPropuestasStatus.error;
        _errorMessage = failure.message;
      },
      (propuestas) {
        // Más recientes primero; las que no traigan fecha (caso raro)
        // se dejan al final en vez de alterar el orden del resto.
        _propuestas = [...propuestas]
          ..sort((a, b) {
            final fechaA = a.createdAt;
            final fechaB = b.createdAt;
            if (fechaA == null && fechaB == null) return 0;
            if (fechaA == null) return 1;
            if (fechaB == null) return -1;
            return fechaB.compareTo(fechaA);
          });
        _status = MisPropuestasStatus.success;
      },
    );
    notifyListeners();
  }
}
