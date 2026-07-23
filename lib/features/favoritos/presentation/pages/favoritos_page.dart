import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/favoritos_provider.dart';
import '../widgets/favorito_card.dart';
import '../widgets/favorito_destino_card.dart';
import '../widgets/favorito_negocio_card.dart';
import '../../../../core/widgets/categoria_chip_selector.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../../../../core/widgets/filtro_chip_option.dart';
import '../../../../core/widgets/section_header_card.dart';
import '../../domain/entities/favorito.dart';
import '../../../home/presentation/widgets/home_app_bar.dart';
import '../../../home/presentation/widgets/custom_bottom_nav_bar.dart';
import '../../../destinos/presentation/providers/destinos_provider.dart';
import '../../../destinos/presentation/pages/lugar_detail_page.dart';
import '../../../destinos/domain/entities/destino.dart';
import '../../../categorias/presentation/providers/categorias_provider.dart';
import '../../../negocio/domain/entities/negocio.dart';
import '../../../negocio/domain/usecases/obtener_negocio_por_id.dart';
import '../../../negocio/presentation/pages/negocio_datalle_page.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/skeleton_loader.dart';

const String _filtroGeneral = 'general';
const String _filtroNegocios = 'negocios';

/// Vista de Favoritos.
///
/// La API de favoritos solo da targetType/targetId/addedAt:
/// - Para destinos, cruzamos contra [DestinoProvider.destinos] (si ya
///   está cargado, o lo cargamos aquí) para mostrar nombre/imagen/
///   calificación/categoría reales.
/// - Para negocios, resolvemos cada uno vía [ObtenerNegocioPorId] (no
///   existe todavía un NegocioProvider global en el árbol de widgets)
///   y cacheamos el resultado localmente en esta pantalla.
///
/// Las categorías del selector se cargan dinámicamente desde
/// [CategoriasProvider] (backend real, `aplicaADestinos`) — nunca están
/// hardcodeadas. Los negocios no tienen categoría propia en el backend
/// (usan un catálogo de "tipo de negocio" aparte), así que viven en su
/// propia pestaña fija "Negocios", junto a la pestaña fija "General".
class FavoritosPage extends StatefulWidget {
  const FavoritosPage({super.key});

  @override
  State<FavoritosPage> createState() => _FavoritosPageState();
}

class _FavoritosPageState extends State<FavoritosPage> {
  final _obtenerNegocioPorId = getIt<ObtenerNegocioPorId>();

  String _categoriaSeleccionada = _filtroGeneral;
  final Map<String, Negocio> _negociosResueltos = {};
  bool _resolviendoNegocios = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargarTodo());
  }

  Future<void> _cargarTodo() async {
    if (!mounted) return;
    final favoritosProvider = context.read<FavoritosProvider>();
    context.read<CategoriasProvider>().cargarSiHaceFalta();

    final destinoProvider = context.read<DestinoProvider>();
    if (!destinoProvider.hasDestinos) {
      destinoProvider.loadDestinos();
    }

    await favoritosProvider.cargarFavoritos();
    if (!mounted) return;
    await _resolverNegocios(favoritosProvider.negociosFavoritos);
  }

  /// Resuelve nombre/imagen/categoría de cada negocio favorito. Cada uno
  /// se intenta por separado: si uno falla (ej. negocio eliminado del
  /// backend), simplemente se omite — nunca detiene ni rompe la carga
  /// de los demás.
  Future<void> _resolverNegocios(List<Favorito> negociosFavoritos) async {
    final pendientes = negociosFavoritos
        .where((f) => !_negociosResueltos.containsKey(f.targetId))
        .toList();
    if (pendientes.isEmpty) return;

    if (mounted) setState(() => _resolviendoNegocios = true);

    await Future.wait(
      pendientes.map((favorito) async {
        try {
          final result = await _obtenerNegocioPorId(favorito.targetId);
          result.fold(
            (failure) {}, // negocio eliminado / inexistente: se omite
            (negocio) => _negociosResueltos[favorito.targetId] = negocio,
          );
        } catch (_) {
          // Excepción inesperada al resolver un negocio: se omite ese
          // ítem puntual, el resto de la pantalla sigue funcionando.
        }
      }),
    );

    if (mounted) setState(() => _resolviendoNegocios = false);
  }

  /// Busca el destino real en DestinoProvider por id, si ya se cargó.
  Destino? _buscarDestino(String targetId) {
    final destinos = context.read<DestinoProvider>().destinos;
    for (final d in destinos) {
      if (d.id == targetId) return d;
    }
    return null;
  }

  void _abrirDetalleDestino(Destino destino, String categoriaNombre) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LugarDetailPage(
          id: destino.id,
          nombre: destino.name,
          categoria: categoriaNombre,
          calificacion: destino.averageRating,
          imageUrl: destino.imageUrl ?? '',
          descripcion: destino.description,
          totalResenas: destino.totalReviews,
          targetType: 'destination',
          categoryId: destino.categoryId,
          locationId: destino.locationId,
          isSaturated: destino.isSaturated,
        ),
      ),
    );
  }

  void _abrirDetalleNegocio(Negocio negocio) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NegocioDetallePage(negocioId: negocio.id),
      ),
    );
  }

  void _irAPlanificarRuta() => Navigator.pushNamed(context, '/mapa');

  Future<void> _quitarFavorito(
    FavoritosProvider provider,
    String targetType,
    String targetId,
    String Function(String) s,
  ) async {
    final ok = await provider.quitarFavorito(
      targetType: targetType,
      targetId: targetId,
    );
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? s('error_quitar_favorito')),
          backgroundColor: AppColors.error(context),
        ),
      );
    }
  }

  void _onNavTap(BottomNavTab tab) {
    switch (tab) {
      case BottomNavTab.explorar:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case BottomNavTab.mapa:
        Navigator.pushReplacementNamed(context, '/mapa');
        break;
      case BottomNavTab.resenas:
        Navigator.pushReplacementNamed(context, '/resenas');
        break;
      case BottomNavTab.perfil:
        Navigator.pushReplacementNamed(context, '/perfil');
        break;
      case BottomNavTab.favoritos:
        break; // ya estamos aquí
    }
  }

  List<FiltroChipOption> _construirOpciones(
    CategoriasProvider categoriasProvider,
    String Function(String) s,
  ) {
    return [
      FiltroChipOption(
        id: _filtroGeneral,
        label: s('filtro_general'),
        icon: Icons.apps_rounded,
      ),
      for (final categoria in categoriasProvider.categoriasDeDestinos)
        FiltroChipOption(
          id: categoria.id,
          label: categoria.nombre,
          icon: Icons.label_outline_rounded,
        ),
      FiltroChipOption(
        id: _filtroNegocios,
        label: s('filtro_negocios'),
        icon: Icons.storefront_rounded,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.width >= 600;
    final lang = context.watch<LocaleProvider>().langCode;
    String s(String k) => AppStrings.tr(k, lang);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: const HomeAppBar(),
      body: Consumer2<FavoritosProvider, CategoriasProvider>(
        builder: (context, favoritosProvider, categoriasProvider, child) {
          final opciones = _construirOpciones(categoriasProvider, s);
          final idsValidos = opciones.map((o) => o.id).toSet();
          // "Categorías inexistentes": si la categoría seleccionada ya no
          // aparece en el catálogo (recarga, categoría eliminada), se cae
          // a "General" en vez de mostrar una pestaña vacía sin salida.
          final categoriaActiva = idsValidos.contains(_categoriaSeleccionada)
              ? _categoriaSeleccionada
              : _filtroGeneral;

          return Column(
            children: [
              SectionHeaderCard(
                icon: Icons.favorite_rounded,
                titulo: s('favoritos_titulo'),
                subtitulo: s('favoritos_subtitulo'),
                total: favoritosProvider.favoritos.length,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                child: CategoriaChipSelector(
                  opciones: opciones,
                  seleccionId: categoriaActiva,
                  onChanged: (id) =>
                      setState(() => _categoriaSeleccionada = id),
                ),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.03),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: KeyedSubtree(
                    key: ValueKey(
                      '$categoriaActiva-${favoritosProvider.status}-$_resolviendoNegocios',
                    ),
                    child: _buildContenido(
                      context,
                      favoritosProvider,
                      categoriasProvider,
                      categoriaActiva,
                      isTablet,
                      s,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: AppBottomNav(
        navItems: AppBottomNav.items,
        currentTab: BottomNavTab.favoritos,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildContenido(
    BuildContext context,
    FavoritosProvider provider,
    CategoriasProvider categoriasProvider,
    String categoriaActiva,
    bool isTablet,
    String Function(String) s,
  ) {
    if (provider.status == FavoritosStatus.loading) {
      return const SkeletonFavoritosGrid(count: 4);
    }

    if (provider.status == FavoritosStatus.error) {
      return ErrorStateView(
        mensaje: provider.errorMessage ?? s('error_favoritos'),
        retryLabel: s('reintentar'),
        onRetry: _cargarTodo,
      );
    }

    if (provider.favoritos.isEmpty) {
      return EmptyStateView(
        mensaje: s('sin_favoritos'),
        icon: Icons.favorite_border_rounded,
      );
    }

    if (categoriaActiva == _filtroNegocios) {
      return _buildTabNegocios(provider, s);
    }

    if (categoriaActiva == _filtroGeneral) {
      return _buildTabGeneral(provider, categoriasProvider, isTablet, s);
    }

    return _buildTabCategoria(provider, categoriasProvider, categoriaActiva, s);
  }

  Widget _buildTabGeneral(
    FavoritosProvider provider,
    CategoriasProvider categoriasProvider,
    bool isTablet,
    String Function(String) s,
  ) {
    final items = provider.favoritos;
    final crossAxisCount = isTablet ? 3 : 2;

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final favorito = items[i];
        final esDestino = favorito.targetType == FavoritoTargetType.destination;

        final destinoReal = esDestino
            ? _buscarDestino(favorito.targetId)
            : null;
        final negocioReal = !esDestino
            ? _negociosResueltos[favorito.targetId]
            : null;

        return FavoritoCard(
          targetType: favorito.targetType,
          targetId: favorito.targetId,
          nombre: destinoReal?.name ?? negocioReal?.nombre,
          subtitulo: destinoReal != null
              ? categoriasProvider.nombrePorId(destinoReal.categoryId)
              : negocioReal?.tipoNegocioNombre,
          imageUrl: destinoReal?.imageUrl ?? negocioReal?.imagenPrincipal,
          calificacion:
              destinoReal?.averageRating ?? negocioReal?.calificacionPromedio,
          procesando: provider.estaProcesando(
            favorito.targetType,
            favorito.targetId,
          ),
          onTap: destinoReal != null
              ? () => _abrirDetalleDestino(
                  destinoReal,
                  categoriasProvider.nombrePorId(destinoReal.categoryId),
                )
              : (negocioReal != null
                    ? () => _abrirDetalleNegocio(negocioReal)
                    : null),
          onQuitar: () => _quitarFavorito(
            provider,
            favorito.targetType,
            favorito.targetId,
            s,
          ),
        );
      },
    );
  }

  Widget _buildTabNegocios(
    FavoritosProvider provider,
    String Function(String) s,
  ) {
    if (_resolviendoNegocios) {
      return const SkeletonFavoritosGrid(count: 3);
    }

    final negociosFavoritos = provider.negociosFavoritos;
    if (negociosFavoritos.isEmpty) {
      return EmptyStateView(
        mensaje: s('sin_favoritos'),
        icon: Icons.storefront_outlined,
      );
    }

    final resueltos = negociosFavoritos
        .map((f) => (favorito: f, negocio: _negociosResueltos[f.targetId]))
        .where((e) => e.negocio != null)
        .toList();

    if (resueltos.isEmpty) {
      return EmptyStateView(
        mensaje: 'No se pudieron cargar tus negocios guardados',
        icon: Icons.error_outline_rounded,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
      itemCount: resueltos.length,
      itemBuilder: (context, i) {
        final entry = resueltos[i];
        final negocio = entry.negocio!;
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: FavoritoNegocioCard(
            negocio: negocio,
            guardadoEl: entry.favorito.createdAt,
            procesandoFavorito: provider.estaProcesando(
              FavoritoTargetType.business,
              entry.favorito.targetId,
            ),
            onTap: () => _abrirDetalleNegocio(negocio),
            onQuitarFavorito: () => _quitarFavorito(
              provider,
              FavoritoTargetType.business,
              entry.favorito.targetId,
              s,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabCategoria(
    FavoritosProvider provider,
    CategoriasProvider categoriasProvider,
    String categoriaId,
    String Function(String) s,
  ) {
    final categoriaNombre = categoriasProvider.nombrePorId(categoriaId);

    final destinosDeCategoria = provider.destinosFavoritos
        .map((f) => (favorito: f, destino: _buscarDestino(f.targetId)))
        .where((e) => e.destino != null && e.destino!.categoryId == categoriaId)
        .toList();

    if (destinosDeCategoria.isEmpty) {
      return EmptyStateView(
        mensaje: 'Sin favoritos en $categoriaNombre',
        icon: Icons.favorite_border_rounded,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
      itemCount: destinosDeCategoria.length,
      itemBuilder: (context, i) {
        final entry = destinosDeCategoria[i];
        final destino = entry.destino!;
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: FavoritoDestinoCard(
            destino: destino,
            categoriaNombre: categoriaNombre,
            guardadoEl: entry.favorito.createdAt,
            procesandoFavorito: provider.estaProcesando(
              FavoritoTargetType.destination,
              entry.favorito.targetId,
            ),
            onTap: () => _abrirDetalleDestino(destino, categoriaNombre),
            onQuitarFavorito: () => _quitarFavorito(
              provider,
              FavoritoTargetType.destination,
              entry.favorito.targetId,
              s,
            ),
            onPlanificarRuta: _irAPlanificarRuta,
          ),
        );
      },
    );
  }
}
