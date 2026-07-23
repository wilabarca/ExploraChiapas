import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/propuesta_destino.dart';
import '../../domain/usecases/crear_propuesta_destino_usecase.dart';
import '../../domain/usecases/sugerir_lugar_usecase.dart';
import '../../domain/usecases/subir_imagenes_propuesta_usecase.dart';

enum RecomendarStatus { idle, enviando, exito, error }

/// Paso conceptual actual del envío, para el indicador de progreso de la
/// pantalla ("✓ Preparando ubicación", "✓ Registrando recomendación",
/// "✓ Subiendo fotografías").
enum PasoRecomendacion { ubicacion, propuesta, imagenes }

@injectable
class RecomendarProvider extends ChangeNotifier {
  final SugerirLugarUseCase _sugerirLugar;
  final CrearPropuestaDestinoUseCase _crearPropuesta;
  final SubirImagenesPropuestaUseCase _subirImagenes;

  RecomendarProvider(
    this._sugerirLugar,
    this._crearPropuesta,
    this._subirImagenes,
  );

  RecomendarStatus _status = RecomendarStatus.idle;
  RecomendarStatus get status => _status;

  PasoRecomendacion? _pasoActual;
  PasoRecomendacion? get pasoActual => _pasoActual;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  int? _errorStatusCode;
  int? get errorStatusCode => _errorStatusCode;

  // Se conservan entre reintentos para no volver a crear una ubicación o
  // una propuesta que el backend ya registró con éxito — solo se limpian
  // en reset() (envío completo o el usuario empieza una recomendación
  // nueva desde cero).
  String? _locationId;
  String? _proposalId;

  PropuestaDestino? _propuesta;
  PropuestaDestino? get propuesta => _propuesta;

  /// `true` si la propuesta ya se creó en un intento anterior y solo
  /// falta reintentar la subida de fotos — útil para que la UI explique
  /// por qué un reintento es más rápido la segunda vez.
  bool get propuestaYaCreada => _proposalId != null;

  Future<bool> enviarPropuesta({
    required String name,
    required String description,
    required String categoryId,
    required double latitude,
    required double longitude,
    String? mapProvider,
    required List<String> rutasImagenes,
  }) async {
    _status = RecomendarStatus.enviando;
    _errorMessage = null;
    _errorStatusCode = null;
    notifyListeners();

    if (_locationId == null) {
      _pasoActual = PasoRecomendacion.ubicacion;
      notifyListeners();

      final resultado = await _sugerirLugar(
        latitude: latitude,
        longitude: longitude,
        mapProvider: mapProvider,
      );

      final huboError = resultado.fold(
        (failure) {
          _marcarError(failure);
          return true;
        },
        (ubicacion) {
          _locationId = ubicacion.id;
          return false;
        },
      );
      if (huboError) return false;
    }

    if (_proposalId == null) {
      _pasoActual = PasoRecomendacion.propuesta;
      notifyListeners();

      final resultado = await _crearPropuesta(
        name: name,
        description: description,
        categoryId: categoryId,
        locationId: _locationId!,
      );

      final huboError = resultado.fold(
        (failure) {
          _marcarError(failure);
          return true;
        },
        (propuesta) {
          _proposalId = propuesta.id;
          _propuesta = propuesta;
          return false;
        },
      );
      if (huboError) return false;
    }

    _pasoActual = PasoRecomendacion.imagenes;
    notifyListeners();

    final resultadoImagenes = await _subirImagenes(
      proposalId: _proposalId!,
      rutasImagenes: rutasImagenes,
    );

    return resultadoImagenes.fold(
      (failure) {
        _marcarError(failure);
        return false;
      },
      (propuestaConFotos) {
        _propuesta = propuestaConFotos;
        _status = RecomendarStatus.exito;
        _pasoActual = null;
        notifyListeners();
        return true;
      },
    );
  }

  void _marcarError(Failure failure) {
    _status = RecomendarStatus.error;
    _errorMessage = failure.message;
    _errorStatusCode = failure is ServerFailure ? failure.statusCode : null;
    _pasoActual = null;
    notifyListeners();
  }

  /// Reinicia todo el flujo, incluyendo `locationId`/`proposalId` — solo
  /// debe llamarse tras un envío exitoso o si el usuario decide empezar
  /// una recomendación nueva desde cero, nunca durante un reintento.
  void reset() {
    _status = RecomendarStatus.idle;
    _errorMessage = null;
    _errorStatusCode = null;
    _pasoActual = null;
    _locationId = null;
    _proposalId = null;
    _propuesta = null;
    notifyListeners();
  }
}
