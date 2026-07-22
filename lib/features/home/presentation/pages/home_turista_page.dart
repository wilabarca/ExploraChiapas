import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/home_app_bar.dart';
import '../widgets/planifica_banner.dart';
import '../widgets/section_header.dart';
import '../widgets/destino_card.dart';
import '../widgets/eventos_banner.dart';
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
import '../../../promociones/presentation/providers/promociones_provider.dart';
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

  // Evita que dos refrescos (p. ej. `resumed` + retorno de navegación
  // casi simultáneos) disparen peticiones duplicadas a la API.
  bool _isRefreshingHome = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _cargarDestacadosML();

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

  /// Refresca únicamente los datos dinámicos del Home (promociones y
  /// próximos eventos) sin tocar destinos ni el motor ML. Se usa tanto al
  /// reanudar la app (`resumed`) como al regresar al Home desde otra
  /// pantalla. No limpia los datos visibles antes de la respuesta: si la
  /// petición falla, la sección conserva lo último que se mostró
  /// correctamente (los providers ya no sobreescriben su lista en error).
  Future<void> _refreshDynamicHomeData() async {
    if (!mounted || _isRefreshingHome) return;
    _isRefreshingHome = true;
    try {
      await Future.wait([
        context.read<PromocionesProvider>().cargarPromociones(),
        context.read<EventosProvider>().cargarEventos(proximas: true),
      ]);
    } finally {
      _isRefreshingHome = false;
    }
  }

  Future<void> _onRefresh() async {
    if (!mounted) return;
    await Future.wait([
      context.read<DestinoProvider>().loadDestinos(limit: 10),
      _cargarDestacadosML(),
      _refreshDynamicHomeData(),
    ]);
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
        ),
      ),
    );
  }

  // ── Navegación a la vista de promociones ─────────────────────────────────
  void _irAPromociones() {
    Navigator.pushNamed(context, '/promociones');
  }

  // ── Navegación a eventos: la misma vista con categorías filtrables ──────
  void _irAEventos() {
    Navigator.pushNamed(context, '/eventos');
  }

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
