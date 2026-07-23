import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/home_app_bar.dart';
import '../widgets/planifica_banner.dart';
import '../widgets/section_header.dart';
import '../widgets/destino_card.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../../../destinos/domain/entities/destino.dart';
import '../../../destinos/presentation/pages/lugar_detail_page.dart';
import '../../../destinos/presentation/providers/destinos_provider.dart';
import '../../../favoritos/presentation/providers/favoritos_provider.dart';
import '../../../favoritos/domain/entities/favorito.dart';
import '../../../eventos/domain/entities/evento.dart';
import '../../../eventos/presentation/providers/eventos_provider.dart';
import '../../data/home_api_service.dart';
import '../widgets/negocio_home_card.dart';
import '../../../negocio/domain/entities/negocio.dart';
import '../../../negocio/domain/usecases/obtener_negocio.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/network/ml_api_client.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/skeleton_loader.dart';

class HomeTuristaPage extends StatefulWidget {
  const HomeTuristaPage({super.key});

  @override
  State<HomeTuristaPage> createState() => _HomeTuristaPageState();
}

class _HomeTuristaPageState extends State<HomeTuristaPage> {
  final HomeApiService _apiService = HomeApiService();

  List<PromocionItem> _promociones = [];
  List<Map<String, dynamic>> _destacadosML = [];
  List<Negocio> _restaurantes = [];
  List<Negocio> _hoteles = [];
  bool _cargandoRestaurantes = false;
  bool _cargandoHoteles = false;

  @override
  void initState() {
    super.initState();

    _cargarPromociones();
    _cargarDestacadosML();
    _cargarRestaurantes();
    _cargarHoteles();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final destinoProvider = context.read<DestinoProvider>();
      if (destinoProvider.listStatus == DestinoStatus.idle) {
        destinoProvider.loadDestinos(limit: 10);
      }

      final eventosProvider = context.read<EventosProvider>();
      if (eventosProvider.status == EventosStatus.idle) {
        eventosProvider.cargarEventos(proximas: true);
      }
    });
  }

  Future<void> _cargarPromociones() async {
    try {
      final promos = await _apiService.fetchPromociones();
      if (!mounted) return;
      setState(() => _promociones = promos);
    } catch (_) {
      // Las promociones no bloquean la pantalla principal.
    }
  }

  Future<void> _cargarDestacadosML() async {
    final resultados = await getIt<MlApiClient>().fetchDestacados(limite: 10);
    if (!mounted) return;
    setState(() => _destacadosML = resultados);
  }

  Future<void> _cargarRestaurantes() async {
    setState(() => _cargandoRestaurantes = true);
    final result =
        await getIt<ObtenerNegocios>()(tipoNegocioId: 'restaurante');
    if (!mounted) return;
    result.fold(
      (_) {},
      (lista) => setState(() => _restaurantes = lista),
    );
    if (mounted) setState(() => _cargandoRestaurantes = false);
  }

  Future<void> _cargarHoteles() async {
    setState(() => _cargandoHoteles = true);
    final result = await getIt<ObtenerNegocios>()(tipoNegocioId: 'hotel');
    if (!mounted) return;
    result.fold(
      (_) {},
      (lista) => setState(() => _hoteles = lista),
    );
    if (mounted) setState(() => _cargandoHoteles = false);
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

  // ── Navegación reutilizable hacia la lista de negocios por tipo ─────────
  void _irANegocios(String tipoNegocioId, String tituloTipo) {
    Navigator.pushNamed(
      context,
      '/negocios',
      arguments: {'tipoNegocioId': tipoNegocioId, 'tituloTipo': tituloTipo},
    );
  }

  // ── Navegación a la vista de promociones ─────────────────────────────────
  void _irAPromociones() {
    Navigator.pushNamed(context, '/promociones');
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
          child: ListView(
            padding: EdgeInsets.only(
              left: isTablet ? (isLarge ? 40 : 24) : 0,
              right: isTablet ? (isLarge ? 40 : 24) : 0,
              bottom: 90 + bottomSafePadding,
            ),
            children: [
              const SizedBox(height: 16),

              const PlanificaBanner(),
              const SizedBox(height: 24),

              SectionHeader(
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
              const SizedBox(height: 14),

              LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = MediaQuery.of(context).size.width;
                  final cardHeight = screenWidth < 360 ? 225.0 : 210.0;

                  return Consumer<DestinoProvider>(
                    builder: (context, destinoProvider, child) {
                      final favProvider = context.watch<FavoritosProvider>();
                      if (destinoProvider.listStatus == DestinoStatus.loading) {
                        return SkeletonCardRow(
                          count: 3,
                          cardHeight: cardHeight,
                          cardWidth: 180,
                        );
                      }

                      if (destinoProvider.listStatus == DestinoStatus.error) {
                        return SizedBox(
                          height: cardHeight,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
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
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _destacadosML.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final d = _destacadosML[index];
                              return DestinoCard(
                                nombre: d['nombre'] as String? ?? '',
                                categoria: d['categoria'] as String? ?? 'destino',
                                calificacion: 0,
                                imageUrl: d['foto_principal'] as String?,
                                esFavorito: false,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => LugarDetailPage(
                                      id: d['id']?.toString() ?? '',
                                      nombre: d['nombre'] as String? ?? '',
                                      categoria: d['categoria'] as String? ?? 'destino',
                                      calificacion: 0,
                                      imageUrl: d['foto_principal'] as String? ?? '',
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
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: itemCount,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            if (index == destinoProvider.destinos.length) {
                              return const SizedBox(
                                width: 80,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF2E7D32),
                                  ),
                                ),
                              );
                            }

                            final destino = destinoProvider.destinos[index];
                            final esFav = favProvider.esFavorito(
                              FavoritoTargetType.destination, destino.id);

                            return DestinoCard(
                              nombre: destino.name,
                              categoria: s('destino_turistico'),
                              calificacion: destino.averageRating,
                              imageUrl: destino.imageUrl,
                              esFavorito: esFav,
                              onTap: () => _openDestinoDetail(destino),
                              onFavoritoTap: () => favProvider.toggleFavorito(
                                targetType: FavoritoTargetType.destination,
                                targetId: destino.id,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 24),

              // ── 🔥 Promociones ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _PromocionesBanner(onTap: _irAPromociones),
              ),

              const SizedBox(height: 24),

              if (_promociones.isNotEmpty) ...[
                SectionHeader(
                  icon: Icons.local_offer_outlined,
                  titulo: s('promociones_activas'),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  // 130 se quedaba corto: título + negocio + 2 líneas de
                  // descripción + precio necesitan más alto y desbordaban.
                  height: 172,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _promociones.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final promo = _promociones[index];
                      return _PromocionCard(promo: promo);
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // ── Próximos eventos (dinámico vía EventosProvider) ──────
              Consumer<EventosProvider>(
                builder: (context, eventosProvider, child) {
                  if (eventosProvider.status == EventosStatus.loading) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        SkeletonEventoItem(),
                        SkeletonEventoItem(),
                      ],
                    );
                  }

                  if (eventosProvider.status == EventosStatus.error) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _SeccionError(
                        message:
                            eventosProvider.errorMessage ??
                            s('error_eventos_carga'),
                        onRetry: () =>
                            eventosProvider.cargarEventos(proximas: true),
                      ),
                    );
                  }

                  if (eventosProvider.eventos.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(
                        icon: Icons.event_outlined,
                        titulo: s('proximos_eventos'),
                        mostrarVerTodos: true,
                        onVerTodos: () =>
                            Navigator.pushNamed(context, '/eventos'),
                      ),
                      const SizedBox(height: 14),
                      ...eventosProvider.eventos.map(
                        (evento) => _EventoItem(evento: evento),
                      ),
                      const SizedBox(height: 24),
                    ],
                  );
                },
              ),

              // ── Turismo Sostenible ────────────────────────────────────
              _SostenibleSection(onVerMapa: () => Navigator.pushNamed(context, '/mapa')),
              const SizedBox(height: 24),

              SectionHeader(
                icon: Icons.restaurant_outlined,
                titulo: s('restaurantes_destacados'),
                mostrarVerTodos: true,
                onVerTodos: () => _irANegocios('restaurante', s('restaurantes')),
              ),
              const SizedBox(height: 14),
              _buildRestaurantes(isTablet, s),

              const SizedBox(height: 24),

              SectionHeader(
                icon: Icons.hotel_outlined,
                titulo: s('hoteles_recomendados'),
                mostrarVerTodos: true,
                onVerTodos: () => _irANegocios('hotel', s('hoteles')),
              ),
              const SizedBox(height: 14),
              _buildHoteles(isTablet, isLarge, s),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/chat'),
        backgroundColor: AppColors.primary(context),
        child: const Icon(Icons.smart_toy_outlined, color: Colors.white),
      ),
      bottomNavigationBar: AppBottomNav(
        navItems: AppBottomNav.items,
        currentTab: BottomNavTab.explorar,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildRestaurantes(bool isTablet, String Function(String) s) {
    if (_cargandoRestaurantes) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_restaurantes.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _restaurantes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => NegocioHomeCard(
          negocio: _restaurantes[i],
          onTap: () => _irANegocios('restaurante', s('restaurantes')),
        ),
      ),
    );
  }

  Widget _buildHoteles(bool isTablet, bool isLarge, String Function(String) s) {
    if (_cargandoHoteles) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_hoteles.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _hoteles.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => NegocioHomeCard(
          negocio: _hoteles[i],
          onTap: () => _irANegocios('hotel', s('hoteles')),
        ),
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
        border: Border.all(color: const Color(0xFFFFCDD2)),
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
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary(context)),
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

class _PromocionCard extends StatelessWidget {
  final PromocionItem promo;

  const _PromocionCard({required this.promo});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8F5E9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.local_offer, size: 16, color: AppColors.primary(context)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  promo.titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ),
            ],
          ),
          if (promo.negocioNombre != null) ...[
            const SizedBox(height: 6),
            Text(
              promo.negocioNombre!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context)),
            ),
          ],
          if (promo.descripcion != null) ...[
            const SizedBox(height: 6),
            Text(
              promo.descripcion!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context)),
            ),
          ],
          const Spacer(),
          if (promo.precio != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer(context),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '\$${promo.precio!.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary(context),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Card "🔥 Promociones" — reutilizable, responsiva ────────────────────────
class _PromocionesBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _PromocionesBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LocaleProvider>().langCode;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 560;

        return GestureDetector(
          onTap: onTap,
          child: AspectRatio(
            // AspectRatio: la card mantiene proporción consistente sin
            // importar el ancho de pantalla.
            aspectRatio: isTablet ? 4.6 / 1.6 : 2.9 / 1.6,
            child: Container(
              padding: EdgeInsets.all(isTablet ? 22 : 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary(context),
                    Color.lerp(AppColors.primary(context), Colors.black, 0.25)!,
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -12,
                    bottom: -12,
                    child: Icon(
                      Icons.local_offer,
                      size: isTablet ? 100 : 78,
                      color: Colors.white.withOpacity(0.14),
                    ),
                  ),
                  Row(
                    children: [
                      // Expanded: el texto ocupa el espacio disponible sin
                      // empujar el ícono.
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  '🔥',
                                  style: TextStyle(fontSize: 15),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  AppStrings.tr('promociones_label', lang),
                                  style: TextStyle(
                                    fontSize: isTablet ? 12 : 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: isTablet ? 10 : 8),
                            // Flexible: la descripción se recorta si no cabe.
                            Flexible(
                              child: Text(
                                AppStrings.tr('promociones_desc', lang),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: isTablet ? 14 : 12.5,
                                  color: Colors.white.withOpacity(0.92),
                                  height: 1.35,
                                ),
                              ),
                            ),
                            // Spacer: empuja el enlace hacia el fondo cuando
                            // hay espacio vertical disponible.
                            const Spacer(),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  AppStrings.tr('ver_promociones', lang),
                                  style: TextStyle(
                                    fontSize: isTablet ? 13.5 : 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.arrow_forward,
                                  size: 15,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Sección de Turismo Sostenible ────────────────────────────────────────────
class _SostenibleSection extends StatelessWidget {
  final VoidCallback onVerMapa;
  const _SostenibleSection({required this.onVerMapa});

  static const _consejos = [
    _Consejo(
      icon: Icons.nature_people_outlined,
      texto: 'Respeta las áreas naturales y no dejes basura.',
    ),
    _Consejo(
      icon: Icons.storefront_outlined,
      texto: 'Consume en negocios locales y artesanías regionales.',
    ),
    _Consejo(
      icon: Icons.groups_outlined,
      texto: 'Prefiere guías de turismo locales certificados.',
    ),
    _Consejo(
      icon: Icons.map_outlined,
      texto: 'Explora rutas alternativas para evitar zonas saturadas.',
    ),
  ];

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
        SectionHeader(
          icon: Icons.eco_outlined,
          titulo: 'Turismo Sostenible',
        ),
        const SizedBox(height: 14),

        // Banner de consejos
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary(context).withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.eco,
                      color: AppColors.primary(context),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Viaja con responsabilidad',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._consejos.map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(c.icon, size: 16, color: AppColors.primary(context)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            c.texto,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary(context),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

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

class _Consejo {
  final IconData icon;
  final String texto;
  const _Consejo({required this.icon, required this.texto});
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

// ── Formatea una fecha como "14 jul" sin depender del paquete intl ─────────
String _formatearFecha(DateTime fecha) {
  const meses = [
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic',
  ];
  return '${fecha.day} ${meses[fecha.month - 1]}';
}

// ── Card de evento — usa Evento del dominio ─────────────────────────────────
class _EventoItem extends StatelessWidget {
  final Evento evento;

  const _EventoItem({required this.evento});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer(context),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.event,
                color: AppColors.primary(context),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    evento.titulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 12,
                        color: AppColors.textSecondary(context),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatearFecha(evento.fechaInicio),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                      if (evento.municipio != null) ...[
                        const SizedBox(width: 10),
                        Icon(
                          Icons.place_outlined,
                          size: 12,
                          color: AppColors.textSecondary(context),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            evento.municipio!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
