import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/categoria.dart';
import '../../domain/usecases/get_categorias_usecase.dart';

enum CategoriasStatus { idle, loading, success, error }

@injectable
class CategoriasProvider extends ChangeNotifier {
  final GetCategoriasUseCase _getCategorias;

  CategoriasProvider(this._getCategorias);

  CategoriasStatus _status = CategoriasStatus.idle;
  CategoriasStatus get status => _status;

  List<Categoria> _categorias = const [];
  List<Categoria> get categorias => _categorias;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<Categoria> get categoriasDeDestinos =>
      _categorias.where((c) => c.aplicaADestinos).toList();

  // Evita relanzar la petición si ya se cargaron una vez (el catálogo de
  // categorías cambia muy poco, no hace falta recargarlo en cada pantalla).
  Future<void> cargarSiHaceFalta() async {
    if (_status == CategoriasStatus.success ||
        _status == CategoriasStatus.loading) {
      return;
    }
    await cargar();
  }

  Future<void> cargar() async {
    _status = CategoriasStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _getCategorias();

    result.fold(
      (failure) {
        _status = CategoriasStatus.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (categorias) {
        _categorias = categorias;
        _status = CategoriasStatus.success;
        notifyListeners();
      },
    );
  }

  /// Nombre de la categoría por id, o [fallback] si no se encuentra
  /// (categoría aún no cargada, o id desconocido).
  String nombrePorId(String? categoryId, {String fallback = 'Otro'}) {
    if (categoryId == null) return fallback;
    for (final categoria in _categorias) {
      if (categoria.id == categoryId) return categoria.nombre;
    }
    return fallback;
  }
}
