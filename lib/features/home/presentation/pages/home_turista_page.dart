import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/home_app_bar.dart';
import '../widgets/planifica_banner.dart';
import '../widgets/section_header.dart';
import '../widgets/destino_card.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/promociones_fuego_banner.dart';
import '../widgets/promociones_activas_section.dart';
import '../widgets/restaurantes_destacados_section.dart';
import '../widgets/hoteles_recomendados_section.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../destinos/domain/entities/destino.dart';
import '../../../destinos/presentation/pages/lugar_detail_page.dart';
import '../../../destinos/presentation/providers/destinos_provider.dart';
import '../../../eventos/presentation/providers/eventos_provider.dart';
import '../../data/home_api_service.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/navigation/app_navigator.dart';
import '../../../../core/network/ml_api_client.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/skeleton_loader.dart';

class HomeTuristaPage extends StatefulWidget {
  const HomeTuristaPage({super.key});

  @override
  State<HomeTuristaPage> createState() => _HomeTuristaPageState();
}

class _HomeTuristaPageState extends State<HomeTuristaPage>
    with WidgetsBindingObserver, RouteAware {
  List<Map<String, dynamic>> _destacadosML = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _cargarDestacadosML();
    _cargarRestaurantes();
    _cargarHoteles();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final destinoProvider = context.read<DestinoProvider>();
      if (destinoProvider.listStatus == DestinoStatus.idle) {
        destinoProvider.loadDestinos(limit: 10);
      }

      final promocionesProvider = context.read<PromocionesProvider>();
      if (promocionesProvider.status == PromocionesStatus.idle) {
        promocionesProvider.cargarPromociones();
      }
    });
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
    WidgetsBinding.instance.removeObserver(this);
    AppNavigator.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshDynamicHomeData();
    }
  }

  // Se dispara cuando el usuario vuelve al Home tras cerrar (pop) una
  // pantalla apilada encima (ej. Promociones, Eventos, Chat).
  @override
  void didPopNext() {
    _refreshDynamicHomeData();
  }

  Future<void> _cargarDestacadosML() async {
    final resultados = await getIt<MlApiClient>().fetchDestacados(limite: 10);
    if (!mounted) return;
    setState(() => _destacadosML = resultados);
  }

  void _onNavTap(BottomNavTab tab) {
    switch (tab) {
      case BottomNavTab.mapa:
        Navigator.pushNamed(context, '/mapa');
        break;
      case BottomNavTab.favoritos:
        Navigator.pushNamed(context, '/favoritos');
        break;
      case BottomNavTab.resenas:
        Navigator.pushNamed(context, '/resenas');
        break;
      case BottomNavTab.perfil:
        Navigator.pushNamed(context, '/perfil');
        break;
      case BottomNavTab.explorar:
        break; // ya estamos aquí
    }
  }

  void _openDestinoDetail(Destino destino) {
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
    );
  }

  // ── Navegación a la vista de promociones ─────────────────────────────────
  void _irAPromociones() {
    Navigator.pushNamed(context, '/promociones');
  }

  static const _restaurantes = [
    _RestauranteData(
      nombre: 'El Fogón de Jovel',
      calificacion: 4.7,
      distanciaKm: 2.4,
      descripcion: 'Especialidad en cocina de autor regional.',
      imageUrl:
          'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400&q=80',
    ),
    _RestauranteData(
      nombre: 'Café Maya Luxury',
      calificacion: 4.9,
      distanciaKm: 0.8,
      descripcion: 'El mejor café de altura de San Cristóbal.',
      imageUrl:
          'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400&q=80',
    ),
  ];

  static const _hoteles = [
    _HotelData(
      nombre: 'Selva Verde Eco-Resort',
      precioPorNoche: 2400.0,
      imageUrl:
          'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=400&q=80',
    ),
    _HotelData(
      nombre: 'Boutique Casa Lum',
      precioPorNoche: 3100.0,
      imageUrl:
          'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=400&q=80',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // ✅ MediaQuery SOLO dentro de build()
    final mq = MediaQuery.of(context);
    final screenW = mq.size.width;
    final isTablet = screenW >= 600;
    final isLarge = screenW >= 900;
    final bottomSafePadding = mq.padding.bottom;
    final lang = context.watch<LocaleProvider>().langCode;
    String s(String k) => AppStrings.tr(k, lang);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: const HomeAppBar(),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            color: AppColors.primary(context),
            child: ListView(
              padding: EdgeInsets.only(
                left: isTablet ? (isLarge ? 40 : 24) : 0,
                right: isTablet ? (isLarge ? 40 : 24) : 0,
                bottom: 90 + bottomSafePadding,
              ),
              children: [
                const SizedBox(height: 16),

                FadeSlideIn(child: const PlanificaBanner()),
                const SizedBox(height: 24),

                FadeSlideIn(
                  delay: const Duration(milliseconds: 60),
                  child: SectionHeader(
                    icon: Icons.location_on_outlined,
                    titulo: s('destinos_para_ti'),
                    mostrarVerTodos: true,
                    onVerTodos: () {
                      final destinoProvider = context.read<DestinoProvider>();
                      if (destinoProvider.hasMore &&
                          !destinoProvider.isLoadingMore) {
                        destinoProvider.loadMoreDestinos();
                      }
                    },
                  ),
                ),
                const SizedBox(height: 14),

                FadeSlideIn(
                  delay: const Duration(milliseconds: 60),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final screenWidth = MediaQuery.of(context).size.width;
                      final cardHeight = screenWidth < 360 ? 225.0 : 210.0;

                      return Consumer<DestinoProvider>(
                        builder: (context, destinoProvider, child) {
                          if (destinoProvider.listStatus ==
                              DestinoStatus.loading) {
                            return SkeletonCardRow(
                              count: 3,
                              cardHeight: cardHeight,
                              cardWidth: 180,
                            );
                          }

                          if (destinoProvider.listStatus ==
                              DestinoStatus.error) {
                            return SizedBox(
                              height: cardHeight,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: _SeccionError(
                                  message:
                                      destinoProvider.listErrorMessage ??
                                      s('error_destinos'),
                                  onRetry: () {
                                    destinoProvider.loadDestinos(limit: 10);
                                  },
                                ),
                              ),
                            );
                          }

                          // Si el backend no tiene datos usa los del motor ML
                          if (destinoProvider.destinos.isEmpty) {
                            if (_destacadosML.isEmpty) {
                              return SizedBox(
                                height: cardHeight,
                                child: Center(
                                  child: Text(
                                    s('sin_destinos'),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary(context),
                                    ),
                                  ),
                                ),
                              );
                            }
                            return SizedBox(
                              height: cardHeight,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                itemCount: _destacadosML.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 12),
                                itemBuilder: (context, index) {
                                  final d = _destacadosML[index];
                                  return DestinoCard(
                                    nombre: d['nombre'] as String? ?? '',
                                    categoria:
                                        d['categoria'] as String? ?? 'destino',
                                    calificacion: 0,
                                    imageUrl: d['foto_principal'] as String?,
                                    esFavorito: false,
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => LugarDetailPage(
                                          id: d['id']?.toString() ?? '',
                                          nombre: d['nombre'] as String? ?? '',
                                          categoria:
                                              d['categoria'] as String? ??
                                              'destino',
                                          calificacion: 0,
                                          imageUrl:
                                              d['foto_principal'] as String? ??
                                              '',
                                          lat: (d['lat'] as num?)?.toDouble(),
                                          lng: (d['lng'] as num?)?.toDouble(),
                                          // Viene del motor ML, no de una
                                          // fila real del backend: no puede
                                          // recibir reseñas.
                                          targetType: null,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }

                          final itemCount =
                              destinoProvider.destinos.length +
                              (destinoProvider.isLoadingMore ? 1 : 0);

                          return SizedBox(
                            height: cardHeight,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              itemCount: itemCount,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                if (index == destinoProvider.destinos.length) {
                                  return SizedBox(
                                    width: 80,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.primary(context),
                                      ),
                                    ),
                                  );
                                }

                                final destino = destinoProvider.destinos[index];

                                return DestinoCard(
                                  nombre: destino.name,
                                  categoria: s('destino_turistico'),
                                  calificacion: destino.averageRating,
                                  imageUrl: destino.imageUrl,
                                  esFavorito: false,
                                  onTap: () => _openDestinoDetail(destino),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // ── 🔥 Promociones ───────────────────────────────────────────
                FadeSlideIn(
                  delay: const Duration(milliseconds: 120),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: PromocionesFuegoBanner(
                      onTap: _irAPromociones,
                      label: s('promociones_label'),
                      descripcion: s('promociones_desc'),
                      verPromocionesLabel: s('ver_promociones'),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                FadeSlideIn(
                  delay: const Duration(milliseconds: 160),
                  child: PromocionesActivasSection(
                    titulo: s('promociones_activas'),
                  ),
                ),

                // ── Eventos y Actividades ──────────────────────────────────
                FadeSlideIn(
                  delay: const Duration(milliseconds: 200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(
                        icon: Icons.event_outlined,
                        titulo: s('proximos_eventos'),
                      ),
                      const SizedBox(height: 14),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: EventosBanner(onExplorar: _irAEventos),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Turismo Sostenible ────────────────────────────────────
                FadeSlideIn(
                  delay: const Duration(milliseconds: 240),
                  child: _SostenibleSection(
                    onVerMapa: () => Navigator.pushNamed(context, '/mapa'),
                  ),
                ),
                const SizedBox(height: 24),

                FadeSlideIn(
                  delay: const Duration(milliseconds: 280),
                  child: RestaurantesDestacadosSection(
                    titulo: s('restaurantes_destacados'),
                    tituloTipo: s('restaurantes'),
                  ),
                ),

                const SizedBox(height: 24),

                FadeSlideIn(
                  delay: const Duration(milliseconds: 320),
                  child: HotelesRecomendadosSection(
                    titulo: s('hoteles_recomendados'),
                    tituloTipo: s('hoteles'),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/chat'),
        backgroundColor: AppColors.primary(context),
        child: Icon(
          Icons.smart_toy_outlined,
          color: AppColors.onPrimary(context),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        navItems: AppBottomNav.items,
        currentTab: BottomNavTab.explorar,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildRestaurantes(bool isTablet, String Function(String) s) {
    if (isTablet) {
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.6,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: _restaurantes
            .map(
              (r) => GestureDetector(
                onTap: () => _irANegocios('restaurante', s('restaurantes')),
                child: RestauranteItem(
                  nombre: r.nombre,
                  calificacion: r.calificacion,
                  distanciaKm: r.distanciaKm,
                  descripcion: r.descripcion,
                  imageUrl: r.imageUrl,
                ),
              ),
            )
            .toList(),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: _restaurantes
            .map(
              (r) => GestureDetector(
                onTap: () => _irANegocios('restaurante', s('restaurantes')),
                child: RestauranteItem(
                  nombre: r.nombre,
                  calificacion: r.calificacion,
                  distanciaKm: r.distanciaKm,
                  descripcion: r.descripcion,
                  imageUrl: r.imageUrl,
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildHoteles(bool isTablet, bool isLarge, String Function(String) s) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;

        if (isTablet) {
          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isLarge ? 3 : 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.95,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: _hoteles
                .map(
                  (h) => GestureDetector(
                    onTap: () => _irANegocios('hotel', s('hoteles')),
                    child: HotelCard(
                      nombre: h.nombre,
                      precioPorNoche: h.precioPorNoche,
                      imageUrl: h.imageUrl,
                    ),
                  ),
                )
                .toList(),
          );
        }

        return SizedBox(
          height: 212,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _hoteles.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final h = _hoteles[index];
              return ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: FractionallySizedBox(
                  widthFactor: 0.5,
                  child: GestureDetector(
                    onTap: () => _irANegocios('hotel', s('hoteles')),
                    child: HotelCard(
                      nombre: h.nombre,
                      precioPorNoche: h.precioPorNoche,
                      imageUrl: h.imageUrl,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _RestauranteData {
  final String nombre;
  final double calificacion;
  final double distanciaKm;
  final String descripcion;
  final String imageUrl;

  const _RestauranteData({
    required this.nombre,
    required this.calificacion,
    required this.distanciaKm,
    required this.descripcion,
    required this.imageUrl,
  });
}

class _HotelData {
  final String nombre;
  final double precioPorNoche;
  final String imageUrl;

  const _HotelData({
    required this.nombre,
    required this.precioPorNoche,
    required this.imageUrl,
  });
}

class _SeccionError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _SeccionError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LocaleProvider>().langCode;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.errorContainer(context)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: 36,
            color: AppColors.error(context),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: Text(AppStrings.tr('reintentar', lang)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary(context),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sección de Turismo Sostenible ────────────────────────────────────────────
class _SostenibleSection extends StatelessWidget {
  final VoidCallback onVerMapa;
  const _SostenibleSection({required this.onVerMapa});

  static const _destinosEco = [
    _EcoDestino(
      nombre: 'Reserva Montes Azules',
      categoria: 'Naturaleza',
      imagen:
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&q=80',
    ),
    _EcoDestino(
      nombre: 'Comunidad El Corralito',
      categoria: 'Cultura',
      imagen:
          'https://images.unsplash.com/photo-1518638150340-f706e86654de?w=400&q=80',
    ),
    _EcoDestino(
      nombre: 'Selva Lacandona',
      categoria: 'Naturaleza',
      imagen:
          'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=400&q=80',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(icon: Icons.eco_outlined, titulo: 'Turismo Sostenible'),
        const SizedBox(height: 14),

        // Destinos eco — carrusel horizontal
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _destinosEco.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final d = _destinosEco[i];
              return DestinoCard(
                nombre: d.nombre,
                categoria: d.categoria,
                calificacion: 4.8,
                imageUrl: d.imagen,
                esSostenible: true,
                onTap: onVerMapa,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _EcoDestino {
  final String nombre;
  final String categoria;
  final String imagen;
  const _EcoDestino({
    required this.nombre,
    required this.categoria,
    required this.imagen,
  });
}
