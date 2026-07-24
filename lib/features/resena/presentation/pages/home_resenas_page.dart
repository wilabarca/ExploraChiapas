import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../../core/widgets/section_header_card.dart';
import '../../../../core/widgets/categoria_chip_selector.dart';
import '../../../../core/widgets/filtro_chip_option.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../../../../core/navigation/app_navigator.dart';
import '../widgets/resena_feed_card.dart';
import '../../../home/presentation/widgets/home_app_bar.dart';
import '../../../home/presentation/widgets/custom_bottom_nav_bar.dart';
import '../../../destinos/presentation/pages/lugar_detail_page.dart';
import '../../../negocio/presentation/pages/negocio_datalle_page.dart';
import '../../../categorias/presentation/providers/categorias_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../providers/resenas_feed_provider.dart';

const String _filtroGeneral = 'general';

/// Feed real de reseñas: agrega, vía [ResenasFeedProvider], las reseñas
/// de todos los destinos y negocios disponibles, filtrable por categoría
/// real (de destinos y de tipos de negocio) — no hay reseñas inventadas
/// ni categorías hardcodeadas, todo sale de lo que el backend devuelve.
///
/// Se refresca solo al volver a esta pantalla (`RouteAware.didPopNext`,
/// el mismo patrón ya usado en el Home para promociones/eventos) — así,
/// justo después de publicar/editar/eliminar una reseña desde el
/// detalle de un lugar y regresar aquí, el feed ya está actualizado sin
/// que el usuario tenga que refrescar a mano ni reiniciar la app.
class HomeResenasPage extends StatefulWidget {
  const HomeResenasPage({super.key});

  @override
  State<HomeResenasPage> createState() => _HomeResenasPageState();
}

class _HomeResenasPageState extends State<HomeResenasPage> with RouteAware {
  String _categoriaSeleccionada = _filtroGeneral;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargarTodo());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      AppNavigator.routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    AppNavigator.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() => _cargarTodo();

  void _cargarTodo() {
    if (!mounted) return;
    context.read<CategoriasProvider>().cargarSiHaceFalta();
    context.read<ResenasFeedProvider>().cargar();
    final profileProvider = context.read<ProfileProvider>();
    if (profileProvider.status == ProfileStatus.idle) {
      profileProvider.loadPerfil();
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
      case BottomNavTab.favoritos:
        Navigator.pushReplacementNamed(context, '/favoritos');
        break;
      case BottomNavTab.perfil:
        Navigator.pushReplacementNamed(context, '/perfil');
        break;
      case BottomNavTab.resenas:
        break; // ya estamos aquí
    }
  }

  List<FiltroChipOption> _construirOpciones(
    CategoriasProvider categoriasProvider,
    ResenasFeedProvider feedProvider,
  ) {
    return [
      const FiltroChipOption(
        id: _filtroGeneral,
        label: 'General',
        icon: Icons.apps_rounded,
      ),
      for (final categoria in categoriasProvider.categoriasDeDestinos)
        FiltroChipOption(
          id: categoria.id,
          label: categoria.nombre,
          icon: Icons.label_outline_rounded,
        ),
      for (final tipo in feedProvider.tiposNegocioReales)
        FiltroChipOption(
          id: tipo.key,
          label: tipo.value,
          icon: Icons.storefront_outlined,
        ),
    ];
  }

  void _abrirLugar(ResenaFeedItem item) {
    final destino = item.destino;
    final negocio = item.negocio;

    if (destino != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LugarDetailPage(
            id: destino.id,
            nombre: destino.name,
            categoria: 'Destino turístico',
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
      ).then((_) => _cargarTodo());
      return;
    }

    if (negocio != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NegocioDetallePage(negocioId: negocio.id),
        ),
      ).then((_) => _cargarTodo());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: const HomeAppBar(),
      body: Consumer2<ResenasFeedProvider, CategoriasProvider>(
        builder: (context, feedProvider, categoriasProvider, child) {
          final opciones = _construirOpciones(categoriasProvider, feedProvider);
          final idsValidos = opciones.map((o) => o.id).toSet();
          final categoriaActiva = idsValidos.contains(_categoriaSeleccionada)
              ? _categoriaSeleccionada
              : _filtroGeneral;

          return Column(
            children: [
              SectionHeaderCard(
                icon: Icons.rate_review_rounded,
                titulo: 'Reseñas',
                subtitulo: 'Descubre experiencias reales de otros viajeros',
                total: feedProvider.items.length,
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
                    key: ValueKey('$categoriaActiva-${feedProvider.status}'),
                    child: _buildContenido(
                      context,
                      feedProvider,
                      categoriasProvider,
                      categoriaActiva,
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
        currentTab: BottomNavTab.resenas,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildContenido(
    BuildContext context,
    ResenasFeedProvider feedProvider,
    CategoriasProvider categoriasProvider,
    String categoriaActiva,
  ) {
    if (feedProvider.status == ResenasFeedStatus.loading ||
        feedProvider.status == ResenasFeedStatus.idle) {
      return const SkeletonList(count: 4);
    }

    if (feedProvider.status == ResenasFeedStatus.error) {
      return ErrorStateView(
        mensaje:
            feedProvider.errorMessage ?? 'No fue posible obtener las reseñas',
        onRetry: _cargarTodo,
      );
    }

    if (feedProvider.items.isEmpty) {
      return const EmptyStateView(
        mensaje: 'Todavía no hay reseñas publicadas',
        icon: Icons.rate_review_outlined,
      );
    }

    var itemsFiltrados = feedProvider.items;
    if (categoriaActiva != _filtroGeneral) {
      itemsFiltrados = itemsFiltrados
          .where((item) => item.categoriaId == categoriaActiva)
          .toList();
    }

    if (itemsFiltrados.isEmpty) {
      return EmptyStateView(
        mensaje: 'Sin reseñas en esta categoría',
        icon: Icons.filter_alt_off_outlined,
        accion: OutlinedButton.icon(
          onPressed: () =>
              setState(() => _categoriaSeleccionada = _filtroGeneral),
          icon: const Icon(Icons.apps, size: 18),
          label: const Text('Ver todas las categorías'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary(context),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
      itemCount: itemsFiltrados.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final item = itemsFiltrados[i];
        final categoriaNombre =
            item.categoriaNombreDirecta ??
            categoriasProvider.nombrePorId(item.categoriaId);
        return FadeSlideIn(
          delay: Duration(milliseconds: 35 * i),
          child: ResenaFeedCard(
            item: item,
            categoriaNombre: categoriaNombre,
            onTap: () => _abrirLugar(item),
          ),
        );
      },
    );
  }
}
