import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/evento.dart';
import '../../domain/usecases/get_evento_by_id_usecase.dart';
import '../../domain/usecases/get_eventos_usecase.dart';

enum EventosStatus { idle, loading, success, error }

@injectable
class EventosProvider extends ChangeNotifier {
  final GetEventosUseCase _getEventos;
  final GetEventoByIdUseCase _getEventoById;

  EventosProvider(this._getEventos, this._getEventoById);

  EventosStatus _status = EventosStatus.idle;
  EventosStatus get status => _status;

  List<Evento> _eventos = const [];
  List<Evento> get eventos => _eventos;

  Evento? _seleccionado;
  Evento? get seleccionado => _seleccionado;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> cargarEventos() async {
    _setLoading();
    final result = await _getEventos();
    return result.fold(
      (failure) {
        _setError(failure.message);
        return false;
      },
      (items) {
        _eventos = items;
        _setSuccess();
        return true;
      },
    );
  }

  Future<bool> cargarDetalle(String id) async {
    _setLoading();
    final result = await _getEventoById(id);
    return result.fold(
      (failure) {
        _setError(failure.message);
        return false;
      },
      (item) {
        _seleccionado = item;
        _setSuccess();
        return true;
      },
    );
  }

  void _setLoading() {
    _status = EventosStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setSuccess() {
    _status = EventosStatus.success;
    notifyListeners();
  }

  void _setError(String message) {
    _status = EventosStatus.error;
    _errorMessage = message;
    notifyListeners();
  }
}
