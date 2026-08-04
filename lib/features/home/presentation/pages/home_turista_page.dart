import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../widgets/home_app_bar.dart';
import '../widgets/planifica_banner.dart';
import '../widgets/section_header.dart';
import '../widgets/destino_card.dart';
import '../widgets/eventos_banner.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/promociones_fuego_banner.dart';
import '../widgets/promociones_activas_section.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/press_scale.dart';
import '../widgets/negocio_home_card.dart';
import '../../../negocio/presentation/pages/negocio_datalle_page.dart';
import '../../../destinos/presentation/pages/lugar_detail_page.dart';
import '../../../eventos/presentation/providers/eventos_provider.dart';
import '../../../negocio/domain/entities/negocio.dart';
import '../../../negocio/domain/usecases/obtener_negocio.dart';
import '../../../destinos/domain/entities/destino.dart';
import '../../../destinos/domain/usecases/list_destinos_usecase.dart.dart';
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
  bool _cargandoDestacados = true;
  bool _errorDestacados = false;
  List<Negocio> _negocios = [];
  bool _cargandoNegocios = false;
  List<Destino> _destinosPocoConcurridos = [];
  Position? _userPos;
  final Map<String, double> _distancias = {};

  // Evita que dos refrescos (p. ej. `resumed` + retorno de navegación
  // casi simultáneos) disparen peticiones duplicadas a la API.
  bool _isRefreshingHome = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    getIt<MlApiClient>().warmup();
    _cargarDestacadosML();
    _cargarNegocios();
    _cargarPosicion();
    _cargarDestinosPocoConcurridos();

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

  Future<void> _cargarDestacadosML() async {
    if (!mounted) return;
    setState(() {
      _cargandoDestacados = true;
      _errorDestacados = false;
    });
    try {
      final resultados = await getIt<MlApiClient>().fetchDestacados(limite: 10);
      if (!mounted) return;
      setState(() {
        _destacadosML = resultados;
        _cargandoDestacados = false;
        _errorDestacados = false;
      });
      _calcularDistanciasML(resultados);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _cargandoDestacados = false;
        _errorDestacados = true;
      });
    }
  }

  // Turismo sostenible: destinos reales activos y NO marcados como
  // saturados (`isSaturated == false`, dato real del backend). Se usa el
  // use case directo (no el `DestinoProvider` compartido) para no pisar el
  // filtro/categoría que otras pantallas (Explorar cerca, etc.) tengan
  // cargado en ese mismo provider global.
  Future<void> _cargarDestinosPocoConcurridos() async {
    final result = await getIt<ListDestinosUseCase>()(limit: 30);
    if (!mounted) return;
    result.fold((_) {}, (destinos) {
      final pocoConcurridos =
          destinos.where((d) => d.active && !d.isSaturated).toList()
            ..sort((a, b) => b.averageRating.compareTo(a.averageRating));
      setState(
        () => _destinosPocoConcurridos = pocoConcurridos.take(6).toList(),
      );
    });
  }

  Future<void> _cargarNegocios() async {
    setState(() => _cargandoNegocios = true);
    final result = await getIt<ObtenerNegocios>()();
    if (!mounted) return;
    result.fold((_) {}, (list) => setState(() => _negocios = list));
    if (mounted) setState(() => _cargandoNegocios = false);
  }

  Future<void> _cargarPosicion() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return;
      var p = await Geolocator.checkPermission();
      if (p == LocationPermission.denied)
        p = await Geolocator.requestPermission();
      if (p == LocationPermission.denied ||
          p == LocationPermission.deniedForever)
        return;
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 8),
        ),
      );
      if (!mounted) return;
      _userPos = pos;
      _calcularDistanciasML(_destacadosML);
    } catch (_) {}
  }

  void _calcularDistanciasML(List<Map<String, dynamic>> ml) {
    if (_userPos == null) return;
    for (final d in ml) {
      final id = d['id']?.toString();
      final lat = (d['lat'] as num?)?.toDouble();
      final lng = (d['lng'] as num?)?.toDouble();
      if (id == null || lat == null || lng == null) continue;
      final km = _haversine(_userPos!.latitude, _userPos!.longitude, lat, lng);
      if (mounted) setState(() => _distancias[id] = km);
    }
  }

  double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = (lat2 - lat1) * pi / 180;
    final dLon = (lon2 - lon1) * pi / 180;
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  /// Refresca únicamente los datos dinámicos del Home (promociones y
  /// próximos eventos) sin tocar destinos ni el motor ML.
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
      _cargarDestacadosML(),
      _cargarDestinosPocoConcurridos(),
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

  void _irAPromociones() {
    Navigator.pushNamed(context, '/promociones');
  }

  void _irAEventos() {
    Navigator.pushNamed(context, '/eventos');
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenW = mq.size.width;
    final isTablet = screenW >= 600;
    final isLarge = screenW >= 900;
    final bottomSafePadding = mq.padding.bottom;
    final lang = context.watch<LocaleProvider>().langCode;
    String s(String k) => AppStrings.tr(k, lang);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: const HomeAppBar(esPantallaPrincipal: true),
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
                  ),
                ),
                const SizedBox(height: 14),

                FadeSlideIn(
                  delay: const Duration(milliseconds: 60),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final screenWidth = MediaQuery.of(context).size.width;
                      final cardHeight = screenWidth < 360 ? 255.0 : 240.0;

                      if (_cargandoDestacados) {
                        return SkeletonCardRow(
                          count: 3,
                          cardHeight: cardHeight,
                          cardWidth: 180,
                        );
                      }

                      if (_errorDestacados) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _SeccionError(
                            message:
                                'No se pudieron cargar los destinos.\nVerifica tu conexión.',
                            onRetry: _cargarDestacadosML,
                          ),
                        );
                      }

                      return SizedBox(
                        height: cardHeight,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _destacadosML.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final d = _destacadosML[index];
                            return DestinoCard(
                              nombre: d['nombre'] as String? ?? '',
                              categoria: d['categoria'] as String? ?? 'destino',
                              calificacion: 0,
                              imageUrl: d['foto_principal'] as String?,
                              esFavorito: false,
                              distanciaKm: _distancias[d['id']?.toString()],
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LugarDetailPage(
                                    id: d['id']?.toString() ?? '',
                                    nombre: d['nombre'] as String? ?? '',
                                    categoria:
                                        d['categoria'] as String? ?? 'destino',
                                    calificacion: 0,
                                    imageUrl:
                                        d['foto_principal'] as String? ?? '',
                                    lat: (d['lat'] as num?)?.toDouble(),
                                    lng: (d['lng'] as num?)?.toDouble(),
                                    targetType: 'destination',
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
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

                // ── Negocios registrados ──────────────────────────────────
                FadeSlideIn(
                  delay: const Duration(milliseconds: 240),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(
                        icon: Icons.storefront_outlined,
                        titulo: 'Negocios',
                        mostrarVerTodos: true,
                        onVerTodos: () =>
                            Navigator.pushNamed(context, '/negocios'),
                      ),
                      const SizedBox(height: 14),
                      if (_cargandoNegocios)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: SkeletonCardRow(
                            count: 3,
                            cardHeight: 170,
                            cardWidth: 160,
                          ),
                        )
                      else if (_negocios.isEmpty)
                        const SizedBox.shrink()
                      else
                        SizedBox(
                          height: NegocioHomeCard.alturaRecomendada,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _negocios.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, i) => NegocioHomeCard(
                              negocio: _negocios[i],
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => NegocioDetallePage(
                                    negocioId: _negocios[i].id,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Turismo Sostenible ────────────────────────────────────
                FadeSlideIn(
                  delay: const Duration(milliseconds: 280),
                  child: _SostenibleSection(
                    destinos: _destinosPocoConcurridos,
                    onVerMapa: () => Navigator.pushNamed(context, '/mapa'),
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
// Antes mostraba 3 destinos inventados a mano (nombre, categoría, foto y
// calificación 4.8 fijos) que no venían del backend. Ahora muestra destinos
// reales (activos y con `isSaturated == false`, dato real de la API) más
// contenido genuino de guía: consejos de turismo responsable y una llamada
// a apoyar negocios locales — nada de esto se inventa ni se simula.
class _SostenibleSection extends StatelessWidget {
  final List<Destino> destinos;
  final VoidCallback onVerMapa;
  const _SostenibleSection({required this.destinos, required this.onVerMapa});

  // "Evita las horas y zonas saturadas" se retiró de aquí a pedido: esa
  // función vive de forma visual y funcional en el mapa (leyenda de
  // afluencia + "alternativas menos concurridas"), no como un consejo de
  // texto suelto.
  static const _consejos = [
    (
      Icons.park_outlined,
      'Respeta la flora y fauna',
      'Mantente en los senderos marcados y no alimentes ni molestes a la '
          'vida silvestre.',
    ),
    (
      Icons.delete_outline,
      'No dejes basura',
      'Llévate contigo todo lo que traigas; muchas reservas no cuentan con '
          'recolección.',
    ),
    (
      Icons.storefront_outlined,
      'Consume local',
      'Prefiere negocios y guías de la comunidad: tu visita impacta '
          'directamente en su economía.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(icon: Icons.eco_outlined, titulo: 'Turismo Sostenible'),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Destinos con menor afluencia ahora mismo',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary(context),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Destinos reales, no saturados — carrusel horizontal
        SizedBox(
          height: 200,
          child: destinos.isEmpty
              ? SkeletonCardRow(count: 3, cardHeight: 200, cardWidth: 160)
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: destinos.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, i) {
                    final d = destinos[i];
                    return FadeSlideIn(
                      delay: Duration(milliseconds: 60 * i),
                      offsetY: 10,
                      child: PressScale(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LugarDetailPage(
                              id: d.id,
                              nombre: d.name,
                              categoria: 'destino',
                              calificacion: d.averageRating,
                              imageUrl: d.imageUrl ?? '',
                              targetType: 'destination',
                              isSaturated: d.isSaturated,
                            ),
                          ),
                        ),
                        child: DestinoCard(
                          nombre: d.name,
                          categoria: 'Poco concurrido',
                          calificacion: d.averageRating,
                          imageUrl: d.imageUrl,
                          esSostenible: true,
                        ),
                      ),
                    );
                  },
                ),
        ),

        const SizedBox(height: 20),

        // Consejos de turismo responsable — tarjetas independientes con
        // sombra suave y borde redondeado, en vez de una lista de texto
        // plano, para que se lean con la misma jerarquía visual que el
        // resto del Home.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < _consejos.length; i++)
                FadeSlideIn(
                  delay: Duration(milliseconds: 80 * i),
                  offsetY: 10,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface(context),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: AppColors.isDark(context) ? 0.25 : 0.06,
                            ),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer(context),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _consejos[i].$1,
                              size: 18,
                              color: AppColors.primary(context),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _consejos[i].$2,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary(context),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  _consejos[i].$3,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    height: 1.4,
                                    color: AppColors.textSecondary(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 4),

              // CTA: apoyar negocios locales — abre el mapa interactivo con
              // negocios y destinos recomendados reales, geolocalizados.
              FadeSlideIn(
                delay: Duration(milliseconds: 80 * _consejos.length),
                offsetY: 10,
                child: PressScale(
                  scaleAbajo: 0.98,
                  onTap: onVerMapa,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: AppColors.primary(context),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary(
                            context,
                          ).withValues(alpha: 0.28),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.storefront_outlined,
                          color: AppColors.onPrimary(context),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Apoya negocios locales en el mapa',
                          style: TextStyle(
                            color: AppColors.onPrimary(context),
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
