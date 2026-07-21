import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/home_app_bar.dart';
import '../widgets/planifica_banner.dart';
import '../widgets/section_header.dart';
import '../widgets/destino_card.dart';
import '../widgets/restaurante_item.dart';
import '../widgets/hotel_card.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../../../destinos/domain/entities/destino.dart';
import '../../../destinos/presentation/pages/lugar_detail_page.dart';
import '../../../destinos/presentation/providers/destinos_provider.dart';
import '../../../eventos/domain/entities/evento.dart';
import '../../../eventos/presentation/providers/eventos_provider.dart';
import '../../data/home_api_service.dart';
import '../../../../core/l10n/app_strings.dart';
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

  @override
  void initState() {
    super.initState();

    _cargarPromociones();

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

                      if (destinoProvider.destinos.isEmpty) {
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
                  height: 130,
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
        onPressed: () => Navigator.pushNamed(context, '/planificar'),
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
          height: 200,
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
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFF7A45), Color(0xFFD84315)],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -12,
                    bottom: -12,
                    child: Icon(
                      Icons.local_fire_department,
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
