import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/section_header.dart';
import '../widgets/destino_card.dart';
import '../widgets/eventos_banner.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/promociones_fuego_banner.dart';
import '../widgets/promociones_activas_section.dart';
import '../widgets/restaurantes_destacados_section.dart';
import '../widgets/hoteles_recomendados_section.dart';
import '../../../../core/navigation/app_navigator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../eventos/domain/entities/envento_entity.dart';
import '../../../eventos/domain/entities/evento.dart';
import '../../../eventos/presentation/pages/detalle_evento_page.dart';
import '../../../eventos/presentation/providers/eventos_provider.dart';
import '../../../promociones/presentation/providers/promociones_provider.dart';

class HomeLocalPage extends StatefulWidget {
  const HomeLocalPage({super.key});

  @override
  State<HomeLocalPage> createState() => _HomeLocalPageState();
}

class _HomeLocalPageState extends State<HomeLocalPage>
    with WidgetsBindingObserver, RouteAware {
  // Evita que dos refrescos (p. ej. `resumed` + retorno de navegación
  // casi simultáneos) disparen peticiones duplicadas a la API.
  bool _isRefreshingHome = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
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

  // ── Navegación a la vista de promociones ─────────────────────────────────
  void _irAPromociones() {
    Navigator.pushNamed(context, '/promociones');
  }

  // ── Navegación a eventos: la misma vista con categorías filtrables ──────
  void _irAEventos() {
    Navigator.pushNamed(context, '/eventos');
  }

  // ── Detalle de un evento real de fin de semana ──────────────────────────
  EventoEntity _mapEventoAEntidad(Evento e) {
    return EventoEntity(
      id: e.id,
      titulo: e.titulo,
      descripcion: e.descripcion ?? '',
      fechaInicio: e.fechaInicio,
      fechaFin: e.fechaFin,
      ubicacion: e.municipio ?? 'Chiapas',
      categoria: e.categoriaNombre ?? 'General',
      imageUrl: (e.imagenUrl != null && e.imagenUrl!.isNotEmpty)
          ? e.imagenUrl!
          : 'https://images.unsplash.com/photo-1533587851505-d119e13fa0d7?w=800&q=80',
      activo: e.activo,
      ubicacionId: e.ubicacionId,
    );
  }

  void _abrirEvento(Evento evento) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetalleEventoPage(evento: _mapEventoAEntidad(evento)),
      ),
    );
  }

  /// Refresca únicamente los datos dinámicos del Home (promociones y
  /// próximos eventos). Se usa tanto al reanudar la app (`resumed`) como
  /// al regresar al Home desde otra pantalla y en el pull-to-refresh
  /// manual. No limpia los datos visibles antes de la respuesta: si la
  /// petición falla, la sección conserva lo último que se mostró
  /// correctamente.
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
    await _refreshDynamicHomeData();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final screenW = size.width;
    final isTablet = screenW >= 600;
    final isLarge = screenW >= 900;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: const HomeAppBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/chat'),
        backgroundColor: AppColors.primary(context),
        child: Icon(
          Icons.smart_toy_outlined,
          color: AppColors.onPrimary(context),
        ),
      ),
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
                bottom: 100,
              ),
              children: [
                const SizedBox(height: 16),

                // ── Destinos para ti ───────────────────────────────────────
                FadeSlideIn(
                  child: SectionHeader(
                    icon: Icons.place_outlined,
                    titulo: 'Destinos para ti',
                    mostrarVerTodos: true,
                    onVerTodos: () {},
                  ),
                ),
                const SizedBox(height: 14),
                FadeSlideIn(
                  child: SizedBox(
                    height: size.height * 0.26,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: const [
                        DestinoCard(
                          nombre: 'Cascadas de Agua Azul',
                          categoria: 'Naturaleza',
                          calificacion: 4.9,
                          imageUrl:
                              'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&q=80',
                          esFavorito: true,
                        ),
                        DestinoCard(
                          nombre: 'Zona Arqueológica Palenque',
                          categoria: 'Cultura',
                          calificacion: 4.8,
                          imageUrl:
                              'https://images.unsplash.com/photo-1518638150340-f706e86654de?w=800&q=80',
                        ),
                        DestinoCard(
                          nombre: 'Cañón del Sumidero',
                          categoria: 'Naturaleza',
                          calificacion: 4.7,
                          imageUrl:
                              'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800&q=80',
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Módulo de descubrimiento ───────────────────────────────
                FadeSlideIn(
                  delay: const Duration(milliseconds: 60),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/cerca'),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.primary(context),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.explore_outlined,
                                        color: AppColors.onPrimary(
                                          context,
                                        ).withValues(alpha: 0.7),
                                        size: 14,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'MÓDULO DE DESCUBRIMIENTO',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.onPrimary(
                                            context,
                                          ).withValues(alpha: 0.7),
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Explorar cerca de mí',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.onPrimary(context),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Encuentra rutas urbanas, lugares cercanos y sugerencias personalizadas.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.onPrimary(
                                        context,
                                      ).withValues(alpha: 0.7),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.onPrimary(
                                  context,
                                ).withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.near_me,
                                color: AppColors.onPrimary(context),
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ── 🔥 Promociones ─────────────────────────────────────────
                FadeSlideIn(
                  delay: const Duration(milliseconds: 120),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: PromocionesFuegoBanner(onTap: _irAPromociones),
                  ),
                ),
                const SizedBox(height: 24),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 160),
                  child: const PromocionesActivasSection(
                    titulo: 'Promociones activas',
                  ),
                ),

                // ── Restaurantes destacados ────────────────────────────────
                FadeSlideIn(
                  delay: const Duration(milliseconds: 200),
                  child: const RestaurantesDestacadosSection(
                    titulo: 'Restaurantes destacados',
                    tituloTipo: 'Restaurantes',
                  ),
                ),

                const SizedBox(height: 24),

                // ── Eventos y Actividades ───────────────────────────────────
                FadeSlideIn(
                  delay: const Duration(milliseconds: 240),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(
                        icon: Icons.calendar_today_outlined,
                        titulo: 'Eventos y Actividades',
                      ),
                      const SizedBox(height: 14),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: EventosBanner(onExplorar: _irAEventos),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Crear ruta corta local ──────────────────────────────────
                FadeSlideIn(
                  delay: const Duration(milliseconds: 280),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/chat'),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer(context),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.primary(
                              context,
                            ).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.primary(context),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.alt_route,
                                color: AppColors.onPrimary(context),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Crea tu ruta local',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary(context),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Genera rutas cortas dentro de tu ciudad o municipio.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary(context),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: AppColors.primary(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Actividades de fin de semana — eventos reales (sábado y
                // domingo), sin endpoint propio: filtra client-side sobre
                // lo que ya cargó EventosProvider.
                FadeSlideIn(
                  delay: const Duration(milliseconds: 320),
                  child: Consumer<EventosProvider>(
                    builder: (context, eventosProvider, _) {
                      final actividades = eventosProvider.eventosFinDeSemana;

                      if (eventosProvider.status == EventosStatus.loading &&
                          actividades.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      if (actividades.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'ACTIVIDADES DE FIN DE SEMANA',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary(context),
                                letterSpacing: 1.1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: size.height * 0.22,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              itemCount: actividades.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                final evento = actividades[index];
                                return _ActividadCard(
                                  key: ValueKey(evento.id),
                                  dia:
                                      evento.fechaInicio.weekday ==
                                          DateTime.saturday
                                      ? 'SÁBADO'
                                      : 'DOMINGO',
                                  nombre: evento.titulo,
                                  imageUrl: evento.imagenUrl,
                                  retraso: Duration(milliseconds: 60 * index),
                                  onTap: () => _abrirEvento(evento),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // ── Hoteles recomendados ────────────────────────────────────
                FadeSlideIn(
                  delay: const Duration(milliseconds: 360),
                  child: const HotelesRecomendadosSection(
                    titulo: 'Hoteles recomendados',
                    tituloTipo: 'Hoteles',
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
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

// ── Widget de actividad de fin de semana ─────────────────────────────────────
class _ActividadCard extends StatelessWidget {
  final String dia;
  final String nombre;
  // Real (Evento.imagenUrl) o null si el evento no tiene foto — en ese
  // caso se muestra un ícono, nunca una foto de stock fija.
  final String? imageUrl;
  final Duration retraso;
  final VoidCallback onTap;

  const _ActividadCard({
    super.key,
    required this.dia,
    required this.nombre,
    required this.imageUrl,
    required this.retraso,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      delay: retraso,
      child: _ActividadCardPressable(
        onTap: onTap,
        child: SizedBox(
          width: 150,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 4 / 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: (imageUrl != null && imageUrl!.isNotEmpty)
                          ? CachedNetworkImage(
                              imageUrl: imageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                color: AppColors.primaryContainer(context),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                color: AppColors.primaryContainer(context),
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: AppColors.primary(context),
                                ),
                              ),
                            )
                          : Container(
                              color: AppColors.primaryContainer(context),
                              child: Icon(
                                Icons.celebration_outlined,
                                color: AppColors.primary(context),
                              ),
                            ),
                    ),
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          dia,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                nombre,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(context),
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Envoltura táctil: reduce ligeramente de tamaño al presionar ───────────
// (mismo patrón usado en ExplorarCercaPage — Listener puro para no
// interferir con la detección de tap del GestureDetector interno).
class _ActividadCardPressable extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;

  const _ActividadCardPressable({required this.onTap, required this.child});

  @override
  State<_ActividadCardPressable> createState() =>
      _ActividadCardPressableState();
}

class _ActividadCardPressableState extends State<_ActividadCardPressable> {
  bool _presionado = false;

  void _setPresionado(bool valor) {
    if (_presionado != valor) setState(() => _presionado = valor);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Listener(
        onPointerDown: (_) => _setPresionado(true),
        onPointerUp: (_) => _setPresionado(false),
        onPointerCancel: (_) => _setPresionado(false),
        child: AnimatedScale(
          scale: _presionado ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}
