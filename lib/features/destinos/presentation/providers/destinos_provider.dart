import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/destino.dart';
import '../../domain/usecases/get_destino_by_id_usecase.dart';
import '../../domain/usecases/list_destinos_usecase.dart.dart';

enum DestinoStatus {
  idle,
  loading,
  success,
  error,
}

@injectable
class DestinoProvider extends ChangeNotifier {
  final ListDestinosUseCase _listDestinosUseCase;
  final GetDestinoByIdUseCase _getDestinoByIdUseCase;

  DestinoProvider(
    this._listDestinosUseCase,
    this._getDestinoByIdUseCase,
  );

  // ─────────────────────────────────────────────────────────────
  // Estado del listado
  // ─────────────────────────────────────────────────────────────

  List<Destino> _destinos = <Destino>[];

  UnmodifiableListView<Destino> get destinos {
    return UnmodifiableListView(_destinos);
  }

  DestinoStatus _listStatus = DestinoStatus.idle;

  DestinoStatus get listStatus => _listStatus;

  String? _listErrorMessage;

  String? get listErrorMessage => _listErrorMessage;

  bool get isLoadingDestinos {
    return _listStatus == DestinoStatus.loading;
  }

  bool get hasDestinos {
    return _destinos.isNotEmpty;
  }

  // ─────────────────────────────────────────────────────────────
  // Estado del detalle
  // ─────────────────────────────────────────────────────────────

  Destino? _selectedDestino;

  Destino? get selectedDestino => _selectedDestino;

  DestinoStatus _detailStatus = DestinoStatus.idle;

  DestinoStatus get detailStatus => _detailStatus;

  String? _detailErrorMessage;

  String? get detailErrorMessage => _detailErrorMessage;

  bool get isLoadingDestinoDetail {
    return _detailStatus == DestinoStatus.loading;
  }

  // ─────────────────────────────────────────────────────────────
  // Estado de paginación
  // ─────────────────────────────────────────────────────────────

  int _limit = 20;
  int _offset = 0;

  bool _hasMore = true;
  bool _isLoadingMore = false;

  String? _paginationErrorMessage;

  int get limit => _limit;

  int get offset => _offset;

  bool get hasMore => _hasMore;

  bool get isLoadingMore => _isLoadingMore;

  String? get paginationErrorMessage => _paginationErrorMessage;

  // ─────────────────────────────────────────────────────────────
  // Filtros actuales
  // ─────────────────────────────────────────────────────────────

  String? _categoryId;
  String? _locationId;
  String? _municipality;
  String? _state;

  String? get categoryId => _categoryId;

  String? get locationId => _locationId;

  String? get municipality => _municipality;

  String? get state => _state;

  bool get hasActiveFilters {
    return _categoryId != null ||
        _locationId != null ||
        _municipality != null ||
        _state != null;
  }

  // ─────────────────────────────────────────────────────────────
  // Cargar listado
  // ─────────────────────────────────────────────────────────────

  Future<bool> loadDestinos({
    String? categoryId,
    String? locationId,
    String? municipality,
    String? state,
    int limit = 20,
  }) async {
    _categoryId = _normalizeFilter(categoryId);
    _locationId = _normalizeFilter(locationId);
    _municipality = _normalizeFilter(municipality);
    _state = _normalizeFilter(state);

    _limit = limit > 0 ? limit : 20;
    _offset = 0;
    _hasMore = true;

    _destinos = <Destino>[];
    _listStatus = DestinoStatus.loading;
    _listErrorMessage = null;
    _paginationErrorMessage = null;

    notifyListeners();

    final result = await _listDestinosUseCase(
      categoryId: _categoryId,
      locationId: _locationId,
      municipality: _municipality,
      state: _state,
      limit: _limit,
      offset: _offset,
    );

    return result.fold(
      (failure) {
        _listStatus = DestinoStatus.error;
        _listErrorMessage = failure.message;
        _hasMore = false;

        notifyListeners();

        return false;
      },
      (destinos) {
        _destinos = List<Destino>.from(destinos);
        _offset = destinos.length;
        _hasMore = destinos.length >= _limit;

        _listStatus = DestinoStatus.success;
        _listErrorMessage = null;

        notifyListeners();

        return true;
      },
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Recargar usando los mismos filtros
  // ─────────────────────────────────────────────────────────────

  Future<bool> refreshDestinos() {
    return loadDestinos(
      categoryId: _categoryId,
      locationId: _locationId,
      municipality: _municipality,
      state: _state,
      limit: _limit,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Cargar siguiente página
  // ─────────────────────────────────────────────────────────────

  Future<bool> loadMoreDestinos() async {
    if (_isLoadingMore ||
        !_hasMore ||
        _listStatus == DestinoStatus.loading) {
      return false;
    }

    _isLoadingMore = true;
    _paginationErrorMessage = null;

    notifyListeners();

    final result = await _listDestinosUseCase(
      categoryId: _categoryId,
      locationId: _locationId,
      municipality: _municipality,
      state: _state,
      limit: _limit,
      offset: _offset,
    );

    return result.fold(
      (failure) {
        _isLoadingMore = false;
        _paginationErrorMessage = failure.message;

        notifyListeners();

        return false;
      },
      (newDestinos) {
        _appendWithoutDuplicates(newDestinos);

        _offset += newDestinos.length;
        _hasMore = newDestinos.length >= _limit;
        _isLoadingMore = false;
        _paginationErrorMessage = null;

        notifyListeners();

        return true;
      },
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Obtener detalle
  // ─────────────────────────────────────────────────────────────

  Future<bool> loadDestinoById({
    required String id,
    bool forceRefresh = false,
  }) async {
    final normalizedId = id.trim();

    if (normalizedId.isEmpty) {
      _detailStatus = DestinoStatus.error;
      _detailErrorMessage =
          'El identificador del destino es obligatorio';

      notifyListeners();

      return false;
    }

    if (!forceRefresh &&
        _selectedDestino != null &&
        _selectedDestino!.id == normalizedId) {
      _detailStatus = DestinoStatus.success;
      _detailErrorMessage = null;

      notifyListeners();

      return true;
    }

    _selectedDestino = null;
    _detailStatus = DestinoStatus.loading;
    _detailErrorMessage = null;

    notifyListeners();

    final result = await _getDestinoByIdUseCase(
      id: normalizedId,
    );

    return result.fold(
      (failure) {
        _detailStatus = DestinoStatus.error;
        _detailErrorMessage = failure.message;

        notifyListeners();

        return false;
      },
      (destino) {
        _selectedDestino = destino;
        _detailStatus = DestinoStatus.success;
        _detailErrorMessage = null;

        notifyListeners();

        return true;
      },
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Limpiar estados
  // ─────────────────────────────────────────────────────────────

  void clearSelectedDestino() {
    _selectedDestino = null;
    _detailStatus = DestinoStatus.idle;
    _detailErrorMessage = null;

    notifyListeners();
  }

  void clearFilters() {
    _categoryId = null;
    _locationId = null;
    _municipality = null;
    _state = null;

    notifyListeners();
  }

  void resetListStatus() {
    _listStatus = DestinoStatus.idle;
    _listErrorMessage = null;
    _paginationErrorMessage = null;

    notifyListeners();
  }

  void resetDetailStatus() {
    _detailStatus = DestinoStatus.idle;
    _detailErrorMessage = null;

    notifyListeners();
  }

  void reset() {
    _destinos = <Destino>[];
    _selectedDestino = null;

    _listStatus = DestinoStatus.idle;
    _detailStatus = DestinoStatus.idle;

    _listErrorMessage = null;
    _detailErrorMessage = null;
    _paginationErrorMessage = null;

    _categoryId = null;
    _locationId = null;
    _municipality = null;
    _state = null;

    _limit = 20;
    _offset = 0;
    _hasMore = true;
    _isLoadingMore = false;

    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────
  // Métodos privados
  // ─────────────────────────────────────────────────────────────

  String? _normalizeFilter(String? value) {
    final normalizedValue = value?.trim();

    if (normalizedValue == null || normalizedValue.isEmpty) {
      return null;
    }

    return normalizedValue;
  }

  void _appendWithoutDuplicates(List<Destino> newDestinos) {
    final destinosById = <String, Destino>{
      for (final destino in _destinos) destino.id: destino,
    };

    for (final destino in newDestinos) {
      destinosById[destino.id] = destino;
    }

    _destinos = destinosById.values.toList(growable: true);
  }
}