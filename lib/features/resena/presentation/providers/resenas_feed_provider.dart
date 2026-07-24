import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../../../destinos/domain/entities/destino.dart';
import '../../../destinos/domain/usecases/list_destinos_usecase.dart.dart';
import '../../../negocio/domain/entities/negocio.dart';
import '../../../negocio/domain/usecases/obtener_negocio.dart';
import '../../domain/entities/resena_entity.dart';
import '../../domain/usecases/GetResenasUseCase.dart';

enum ResenasFeedStatus { idle, loading, success, error }

/// Una reseña real ya "enriquecida" con los datos del lugar/negocio al
/// que pertenece, para poder mostrarla en una tarjeta de feed (foto,
/// nombre, categoría) sin que la tarjeta tenga que ir a buscar esos
/// datos por separado.
class ResenaFeedItem {
  final Resena resena;
  final String targetType; // 'destination' | 'business'

  /// Entidad real completa del lugar/negocio (una de las dos, nunca
  /// ambas) — se conserva el objeto original en vez de copiar solo
  /// algunos campos, para que la navegación al detalle use exactamente
  /// los mismos datos que el resto de la app (sin duplicar ni arriesgar
  /// que queden desincronizados).
  final Destino? destino;
  final Negocio? negocio;

  const ResenaFeedItem({
    required this.resena,
    required this.targetType,
    this.destino,
    this.negocio,
  });

  String get lugarNombre => destino?.name ?? negocio?.nombre ?? '';
  String? get lugarImageUrl => destino?.imageUrl ?? negocio?.imagenPrincipal;

  /// Id real de categoría: `categoryId` si es destino, `tipoNegocioId`
  /// si es negocio — se usa para filtrar por categoría en la UI.
  String get categoriaId => destino?.categoryId ?? negocio?.tipoNegocioId ?? '';

  /// Solo viene resuelto para negocios (`tipoNegocioNombre`, ya lo trae
  /// el propio negocio). Para destinos es `null`: el nombre real de la
  /// categoría se resuelve en la UI con `CategoriasProvider`, que ya es
  /// la fuente de verdad para esos nombres en el resto de la app.
  String? get categoriaNombreDirecta => negocio?.tipoNegocioNombre;
}

/// Agrega en un solo feed las reseñas reales de todos los destinos y
/// negocios disponibles a través de los casos de uso existentes
/// (`ListDestinosUseCase`, `ObtenerNegocios`, `GetResenasUseCase`) — no
/// se creó ningún endpoint nuevo: la API no expone "todas las reseñas"
/// de una vez (`GET /reviews` exige `targetType`+`targetId` puntuales),
/// así que este provider hace el trabajo de juntarlas en el cliente,
/// consultando cada lugar en paralelo.
@injectable
class ResenasFeedProvider extends ChangeNotifier {
  final ListDestinosUseCase _listDestinos;
  final ObtenerNegocios _obtenerNegocios;
  final GetResenasUseCase _getResenas;

  ResenasFeedProvider(
    this._listDestinos,
    this._obtenerNegocios,
    this._getResenas,
  );

  ResenasFeedStatus _status = ResenasFeedStatus.idle;
  ResenasFeedStatus get status => _status;

  List<ResenaFeedItem> _items = const [];
  List<ResenaFeedItem> get items => _items;

  /// Tipos de negocio reales presentes en los negocios cargados —
  /// usados para construir chips de filtro adicionales a las
  /// categorías de destinos, sin inventar ninguna categoría.
  List<MapEntry<String, String>> _tiposNegocioReales = const [];
  List<MapEntry<String, String>> get tiposNegocioReales => _tiposNegocioReales;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> cargar() async {
    _status = ResenasFeedStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final destinosResult = await _listDestinos(limit: 40);
      final negociosResult = await _obtenerNegocios();

      final destinos = destinosResult.fold(
        (_) => const <Destino>[],
        (lista) => lista,
      );
      final negocios = negociosResult.fold(
        (_) => const <Negocio>[],
        (lista) => lista,
      );

      _tiposNegocioReales = {
        for (final n in negocios)
          if (n.tipoNegocioId.isNotEmpty) n.tipoNegocioId: n.tipoNegocioNombre,
      }.entries.toList();

      final futuros = <Future<List<ResenaFeedItem>>>[
        for (final destino in destinos) _resenasDeDestino(destino),
        for (final negocio in negocios) _resenasDeNegocio(negocio),
      ];

      final listas = await Future.wait(futuros);
      final todas = listas.expand((lista) => lista).toList()
        ..sort((a, b) => b.resena.createdAt.compareTo(a.resena.createdAt));

      _items = todas;
      _status = ResenasFeedStatus.success;
      notifyListeners();
    } catch (e) {
      _status = ResenasFeedStatus.error;
      _errorMessage = 'No fue posible cargar las reseñas';
      notifyListeners();
    }
  }

  Future<List<ResenaFeedItem>> _resenasDeDestino(Destino destino) async {
    final result = await _getResenas(
      targetType: 'destination',
      targetId: destino.id,
    );
    return result.fold(
      (_) => const [],
      (resenas) => resenas
          .map(
            (resena) => ResenaFeedItem(
              resena: resena,
              targetType: 'destination',
              destino: destino,
            ),
          )
          .toList(),
    );
  }

  Future<List<ResenaFeedItem>> _resenasDeNegocio(Negocio negocio) async {
    final result = await _getResenas(
      targetType: 'business',
      targetId: negocio.id,
    );
    return result.fold(
      (_) => const [],
      (resenas) => resenas
          .map(
            (resena) => ResenaFeedItem(
              resena: resena,
              targetType: 'business',
              negocio: negocio,
            ),
          )
          .toList(),
    );
  }
}
