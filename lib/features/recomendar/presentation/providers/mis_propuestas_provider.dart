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
        _propuestas = propuestas;
        _status = MisPropuestasStatus.success;
      },
    );
    notifyListeners();
  }
}
