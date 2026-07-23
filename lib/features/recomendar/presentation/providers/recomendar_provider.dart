import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/categoria.dart';
import '../../domain/entities/ubicacion_propuesta.dart';
import '../../domain/usecases/crear_propuesta_usecase.dart';
import '../../domain/usecases/crear_ubicacion_usecase.dart';
import '../../domain/usecases/get_categorias_usecase.dart';
import '../../domain/usecases/subir_imagenes_propuesta_usecase.dart';

enum RecomendarStatus {
  idle,
  loadingCategorias,
  listo,
  creandoUbicacion,
  creandoPropuesta,
  subiendoImagenes,
  exito,
  error,
}

@injectable
class RecomendarProvider extends ChangeNotifier {
  final GetCategoriasUseCase _getCategorias;
  final CrearUbicacionUseCase _crearUbicacion;
  final CrearPropuestaUseCase _crearPropuesta;
  final SubirImagenesPropuestaUseCase _subirImagenes;

  RecomendarProvider(
    this._getCategorias,
    this._crearUbicacion,
    this._crearPropuesta,
    this._subirImagenes,
  );

  RecomendarStatus _status = RecomendarStatus.idle;
  RecomendarStatus get status => _status;

  List<Categoria> _categorias = [];
  List<Categoria> get categorias => _categorias;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ID de la propuesta ya creada (para reintentar subida de fotos sin duplicar)
  String? _propuestaIdCreada;
  String? get propuestaIdCreada => _propuestaIdCreada;

  // Estado de éxito para mostrar confirmación
  String? _propuestaIdExito;
  String? get propuestaIdExito => _propuestaIdExito;

  Future<void> cargarCategorias() async {
    if (_status == RecomendarStatus.loadingCategorias) return;
    _status = RecomendarStatus.loadingCategorias;
    _errorMessage = null;
    notifyListeners();

    final result = await _getCategorias();
    result.fold(
      (failure) {
        _status = RecomendarStatus.error;
        _errorMessage = failure.message;
      },
      (cats) {
        _categorias = cats;
        _status = RecomendarStatus.listo;
      },
    );
    notifyListeners();
  }

  Future<void> enviarPropuesta({
    required String nombre,
    required String descripcion,
    required String categoriaId,
    required UbicacionPropuesta ubicacion,
    required List<XFile> imagenes,
  }) async {
    _errorMessage = null;

    // ── Paso 1: crear ubicación ──────────────────────────────────────────────
    _status = RecomendarStatus.creandoUbicacion;
    notifyListeners();

    final ubicacionResult = await _crearUbicacion(ubicacion);
    if (ubicacionResult.isLeft()) {
      _status = RecomendarStatus.error;
      _errorMessage = ubicacionResult.fold((f) => f.message, (_) => null);
      notifyListeners();
      return;
    }
    final locationId = ubicacionResult.getOrElse(() => '');

    // ── Paso 2: crear propuesta (omitir si ya fue creada en intento anterior) ─
    if (_propuestaIdCreada == null) {
      _status = RecomendarStatus.creandoPropuesta;
      notifyListeners();

      final propuestaResult = await _crearPropuesta(
        name: nombre,
        description: descripcion,
        categoryId: categoriaId,
        locationId: locationId,
      );
      if (propuestaResult.isLeft()) {
        _status = RecomendarStatus.error;
        _errorMessage = propuestaResult.fold((f) => f.message, (_) => null);
        notifyListeners();
        return;
      }
      _propuestaIdCreada = propuestaResult.getOrElse(
        () => throw StateError('propuesta vacía'),
      ).id;
    }

    // ── Paso 3: subir fotografías ────────────────────────────────────────────
    _status = RecomendarStatus.subiendoImagenes;
    notifyListeners();

    final imagenesResult = await _subirImagenes(
      proposalId: _propuestaIdCreada!,
      imagenes: imagenes,
    );
    if (imagenesResult.isLeft()) {
      _status = RecomendarStatus.error;
      // Mantiene _propuestaIdCreada para poder reintentar sin duplicar
      _errorMessage =
          '${imagenesResult.fold((f) => f.message, (_) => '')}. '
          'Tu recomendación fue registrada, pero las fotografías no se subieron. '
          'Intenta de nuevo.';
      notifyListeners();
      return;
    }

    // ── Éxito ────────────────────────────────────────────────────────────────
    _propuestaIdExito = _propuestaIdCreada;
    _propuestaIdCreada = null;
    _status = RecomendarStatus.exito;
    notifyListeners();
  }

  /// Permite reintentar solo la subida de imágenes cuando la propuesta ya existe
  Future<void> reintentarImagenes({
    required List<XFile> imagenes,
  }) async {
    if (_propuestaIdCreada == null) return;
    _errorMessage = null;
    _status = RecomendarStatus.subiendoImagenes;
    notifyListeners();

    final result = await _subirImagenes(
      proposalId: _propuestaIdCreada!,
      imagenes: imagenes,
    );
    result.fold(
      (failure) {
        _status = RecomendarStatus.error;
        _errorMessage =
            '${failure.message}. Intenta de nuevo.';
      },
      (_) {
        _propuestaIdExito = _propuestaIdCreada;
        _propuestaIdCreada = null;
        _status = RecomendarStatus.exito;
      },
    );
    notifyListeners();
  }

  void reiniciar() {
    _status = _categorias.isEmpty ? RecomendarStatus.idle : RecomendarStatus.listo;
    _errorMessage = null;
    _propuestaIdCreada = null;
    _propuestaIdExito = null;
    notifyListeners();
  }
}
