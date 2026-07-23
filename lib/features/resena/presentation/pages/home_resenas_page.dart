import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/DestinoResenaEntity.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../../core/widgets/section_header_card.dart';
import '../../../../core/widgets/categoria_chip_selector.dart';
import '../../../../core/widgets/filtro_chip_option.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../widgets/destino_resena_card.dart';
import '../../../home/presentation/widgets/home_app_bar.dart';
import '../../../home/presentation/widgets/custom_bottom_nav_bar.dart';
import '../../../destinos/presentation/providers/destinos_provider.dart';
import '../../../destinos/domain/entities/destino.dart';
import '../../../categorias/presentation/providers/categorias_provider.dart';
import '../pages/detalle_resena_page.dart';

const String _filtroGeneral = 'general';

/// Vista de Reseñas: lista de destinos disponibles para reseñar,
/// filtrable por categoría real del backend (mismo diseño y patrón que
/// Favoritos: encabezado, chips animados, estados vacío/error consistentes
/// y navegación inferior).
///
/// ⚠️ La API de reseñas no da un conteo agregado por destino, y
/// `GET /destinations` hoy puede devolver una lista vacía si todavía no
/// hay destinos cargados en producción — por eso el estado "sin
/// destinos" es real, no un bug: se maneja con su propio diseño en vez
/// de un mensaje genérico.
class HomeResenasPage extends StatefulWidget {
  const HomeResenasPage({super.key});

  @override
  State<HomeResenasPage> createState() => _HomeResenasPageState();
}

class _HomeResenasPageState extends State<HomeResenasPage> {
  String _categoriaSeleccionada = _filtroGeneral;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargarTodo());
  }

  void _cargarTodo() {
    if (!mounted) return;
    final destinoProvider = context.read<DestinoProvider>();
    if (destinoProvider.listStatus == DestinoStatus.idle) {
      destinoProvider.loadDestinos(limit: 20);
    }
    context.read<CategoriasProvider>().cargarSiHaceFalta();
  }

  DestinoResenaEntity _mapDestino(Destino destino, String categoriaNombre) {
    return DestinoResenaEntity(
      id: destino.id,
      nombre: destino.name,
      ubicacion: categoriaNombre,
      imageUrl: (destino.imageUrl != null && destino.imageUrl!.isNotEmpty)
          ? destino.imageUrl!
          : 'https://images.unsplash.com/photo-1518638150340-f706e86654de?w=800&q=80',
      calificacion: destino.averageRating,
      // La API de reseñas no da un conteo agregado por destino todavía.
      totalResenas: destino.totalReviews,
      tipo: categoriaNombre,
      targetType: 'destination',
      esPopular: destino.averageRating >= 4.7,
    );
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
    ];
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: const HomeAppBar(),
      body: Consumer2<DestinoProvider, CategoriasProvider>(
        builder: (context, destinoProvider, categoriasProvider, child) {
          final opciones = _construirOpciones(categoriasProvider);
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
                icon: Icons.rate_review_rounded,
                titulo: 'Reseñas',
                subtitulo: 'Descubre experiencias reales de otros viajeros',
                total: destinoProvider.destinos.length,
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
                      '$categoriaActiva-${destinoProvider.listStatus}',
                    ),
                    child: _buildContenido(
                      context,
                      destinoProvider,
                      categoriasProvider,
                      categoriaActiva,
                      size,
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
    DestinoProvider destinoProvider,
    CategoriasProvider categoriasProvider,
    String categoriaActiva,
    Size size,
  ) {
    if (destinoProvider.listStatus == DestinoStatus.loading) {
      return const SkeletonList(count: 4);
    }

    if (destinoProvider.listStatus == DestinoStatus.error) {
      return ErrorStateView(
        mensaje:
            destinoProvider.listErrorMessage ??
            'No fue posible obtener los destinos',
        onRetry: _cargarTodo,
      );
    }

    // Defensivo: aunque el estado sea "success", una respuesta inesperada
    // (ej. destinos sin id) nunca debe tumbar la pantalla — se filtran
    // silenciosamente los registros incompletos.
    final destinosValidos = destinoProvider.destinos
        .where((d) => d.id.isNotEmpty && d.name.isNotEmpty)
        .toList();

    if (destinosValidos.isEmpty) {
      return const EmptyStateView(
        mensaje: 'Todavía no hay destinos para reseñar',
        icon: Icons.explore_off_outlined,
      );
    }

    List<Destino> destinosFiltrados = destinosValidos;
    if (categoriaActiva != _filtroGeneral) {
      destinosFiltrados = destinosFiltrados
          .where((d) => d.categoryId == categoriaActiva)
          .toList();
    }

    if (destinosFiltrados.isEmpty) {
      return EmptyStateView(
        mensaje: 'Sin destinos en esta categoría',
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

    // ✓ GridView.builder: reorganiza las tarjetas en 2 columnas y las
    // recicla eficientemente al hacer scroll.
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: (size.width / 2 - 22) / (size.height * 0.38),
      ),
      itemCount: destinosFiltrados.length,
      itemBuilder: (context, i) {
        final destinoOriginal = destinosFiltrados[i];
        final categoriaNombre = categoriasProvider.nombrePorId(
          destinoOriginal.categoryId,
        );
        final destino = _mapDestino(destinoOriginal, categoriaNombre);
        return DestinoResenaCard(
          destino: destino,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetalleResenaPage(destino: destino),
            ),
          ),
        );
      },
    );
  }
}
