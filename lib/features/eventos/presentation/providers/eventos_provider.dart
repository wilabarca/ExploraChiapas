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

  /// Eventos reales (activos) cuya fecha de inicio cae en sábado o
  /// domingo, ordenados por fecha más próxima primero. No hace ninguna
  /// petición nueva: filtra sobre lo que ya haya cargado [cargarEventos]
  /// — pensado para secciones tipo "Actividades de fin de semana" que no
  /// necesitan (ni deben) depender de un endpoint propio en el backend.
  List<Evento> get eventosFinDeSemana {
    final lista = _eventos
        .where(
          (e) =>
              e.activo &&
              (e.fechaInicio.weekday == DateTime.saturday ||
                  e.fechaInicio.weekday == DateTime.sunday),
        )
        .toList();
    lista.sort((a, b) => a.fechaInicio.compareTo(b.fechaInicio));
    return lista;
  }

  Future<bool> cargarEventos({bool? proximas}) async {
    _setLoading();
    final result = await _getEventos(proximas: proximas);
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
    final result = await _getEventoById(id: id);
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
