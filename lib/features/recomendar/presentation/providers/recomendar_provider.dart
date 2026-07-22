import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/usecases/sugerir_lugar_usecase.dart';

enum RecomendarStatus { idle, enviando, exito, error }

@injectable
class RecomendarProvider extends ChangeNotifier {
  final SugerirLugarUseCase _sugerirLugar;
  RecomendarProvider(this._sugerirLugar);

  RecomendarStatus _status = RecomendarStatus.idle;
  RecomendarStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  int? _errorStatusCode;
  int? get errorStatusCode => _errorStatusCode;

  Future<bool> enviarSugerencia({
    required double latitude,
    required double longitude,
    String? address,
  }) async {
    _status = RecomendarStatus.enviando;
    _errorMessage = null;
    _errorStatusCode = null;
    notifyListeners();

    final result = await _sugerirLugar(
      latitude: latitude,
      longitude: longitude,
      address: address,
    );

    return result.fold(
      (failure) {
        _status = RecomendarStatus.error;
        _errorMessage = failure.message;
        _errorStatusCode = failure is ServerFailure ? failure.statusCode : null;
        notifyListeners();
        return false;
      },
      (_) {
        _status = RecomendarStatus.exito;
        notifyListeners();
        return true;
      },
    );
  }

  void reset() {
    _status = RecomendarStatus.idle;
    _errorMessage = null;
    _errorStatusCode = null;
    notifyListeners();
  }
}
