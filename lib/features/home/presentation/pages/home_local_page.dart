import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

import '../widgets/home_app_bar.dart';
import '../widgets/section_header.dart';
import '../widgets/destino_card.dart';
import '../widgets/negocio_home_card.dart';
import '../widgets/eventos_banner.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../../../destinos/domain/entities/destino.dart';
import '../../../destinos/presentation/pages/lugar_detail_page.dart';
import '../../../destinos/presentation/providers/destinos_provider.dart';
import '../../../eventos/presentation/providers/eventos_provider.dart';
import '../../../eventos/domain/entities/evento.dart';
import '../../../favoritos/presentation/providers/favoritos_provider.dart';
import '../../../favoritos/domain/entities/favorito.dart';
import '../../../negocio/domain/entities/negocio.dart';
import '../../../negocio/domain/usecases/obtener_negocio.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/network/ml_api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/skeleton_loader.dart';

class HomeLocalPage extends StatefulWidget {
  const HomeLocalPage({super.key});

  @override
  State<HomeLocalPage> createState() => _HomeLocalPageState();
}

class _HomeLocalPageState extends State<HomeLocalPage> {
  List<Map<String, dynamic>> _destacadosML = [];
  List<Negocio> _restaurantes = [];
  List<Negocio> _hoteles = [];
  bool _cargandoRestaurantes = false;
  bool _cargandoHoteles = false;

  @override
  void initState() {
    super.initState();
    _cargarDestacadosML();
    _cargarRestaurantes();
    _cargarHoteles();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final dp = context.read<DestinoProvider>();
      if (dp.listStatus == DestinoStatus.idle) dp.loadDestinos(limit: 10);

      final ep = context.read<EventosProvider>();
      if (ep.status == EventosStatus.idle) ep.cargarEventos(proximas: true);
    });
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
    result.fold((_) {}, (l) => setState(() => _restaurantes = l));
    if (mounted) setState(() => _cargandoRestaurantes = false);
  }

  Future<void> _cargarHoteles() async {
    setState(() => _cargandoHoteles = true);
    final result = await getIt<ObtenerNegocios>()(tipoNegocioId: 'hotel');
    if (!mounted) return;
    result.fold((_) {}, (l) => setState(() => _hoteles = l));
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
        break;
    }
  }

  void _irANegocios(String tipoNegocioId, String titulo) {
    Navigator.pushNamed(
      context,
      '/negocios',
      arguments: {'tipoNegocioId': tipoNegocioId, 'tituloTipo': titulo},
    );
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: const HomeAppBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/chat'),
        backgroundColor: AppColors.primary(context),
        child: const Icon(Icons.smart_toy_outlined, color: Colors.white),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),

          // ── Destinos para ti ───────────────────────────────────────────────
          SectionHeader(
            icon: Icons.place_outlined,
            titulo: 'Destinos para ti',
            mostrarVerTodos: true,
            onVerTodos: () {
              final dp = context.read<DestinoProvider>();
              if (dp.hasMore && !dp.isLoadingMore) dp.loadMoreDestinos();
            },
          ),
          const SizedBox(height: 14),
          _SeccionDestinos(
            destacadosML: _destacadosML,
            cardHeight: size.height * 0.26,
            onDestinoTap: _openDestinoDetail,
          ),

          const SizedBox(height: 24),

          // ── Explorar cerca ────────────────────────────────────────────────
          Padding(
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
                            children: const [
                              Icon(Icons.explore_outlined,
                                  color: Colors.white70, size: 14),
                              SizedBox(width: 6),
                              Text(
                                'MÓDULO DE DESCUBRIMIENTO',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white70,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Explorar cerca de mí',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Encuentra rutas urbanas, lugares cercanos y '
                            'sugerencias personalizadas.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
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
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.near_me,
                          color: Colors.white, size: 24),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── Restaurantes destacados ────────────────────────────────────────
          SectionHeader(
            icon: Icons.restaurant_outlined,
            titulo: 'Restaurantes destacados',
            mostrarVerTodos: true,
            onVerTodos: () => _irANegocios('restaurante', 'Restaurantes'),
          ),
          const SizedBox(height: 14),
          _buildNegocioCarrusel(
            loading: _cargandoRestaurantes,
            negocios: _restaurantes,
            onTap: () => _irANegocios('restaurante', 'Restaurantes'),
          ),

          const SizedBox(height: 24),

          // ── Eventos y Actividades ─────────────────────────────────────────
          SectionHeader(
            icon: Icons.calendar_today_outlined,
            titulo: 'Eventos y Actividades',
            mostrarVerTodos: true,
            onVerTodos: () => Navigator.pushNamed(context, '/eventos'),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: EventosBanner(
              onExplorar: () => Navigator.pushNamed(context, '/eventos'),
            ),
          ),

          const SizedBox(height: 14),

          // ── Próximas actividades (EventosProvider) ────────────────────────
          Consumer<EventosProvider>(
            builder: (context, ep, _) {
              if (ep.status == EventosStatus.loading) {
                return const SizedBox(height: 170, child: SkeletonEventoItem());
              }
              if (ep.eventos.isEmpty) return const SizedBox.shrink();

              return SizedBox(
                height: 170,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: ep.eventos.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) => _ActividadCard(evento: ep.eventos[i]),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // ── Crea tu ruta local ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/chat'),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer(context),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.primary(context).withValues(alpha: 0.3),
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
                      child: const Icon(Icons.alt_route,
                          color: Colors.white, size: 24),
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
                    Icon(Icons.arrow_forward_ios,
                        size: 16, color: AppColors.primary(context)),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── Hoteles recomendados ───────────────────────────────────────────
          SectionHeader(
            icon: Icons.hotel_outlined,
            titulo: 'Hoteles recomendados',
            mostrarVerTodos: true,
            onVerTodos: () => _irANegocios('hotel', 'Hoteles'),
          ),
          const SizedBox(height: 14),
          _buildNegocioCarrusel(
            loading: _cargandoHoteles,
            negocios: _hoteles,
            onTap: () => _irANegocios('hotel', 'Hoteles'),
          ),

          const SizedBox(height: 100),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        navItems: AppBottomNav.items,
        currentTab: BottomNavTab.explorar,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildNegocioCarrusel({
    required bool loading,
    required List<Negocio> negocios,
    required VoidCallback onTap,
  }) {
    if (loading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (negocios.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: negocios.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) =>
            NegocioHomeCard(negocio: negocios[i], onTap: onTap),
      ),
    );
  }
}

// ── Sección de destinos: DestinoProvider + ML fallback ──────────────────────
class _SeccionDestinos extends StatelessWidget {
  final List<Map<String, dynamic>> destacadosML;
  final double cardHeight;
  final void Function(Destino) onDestinoTap;

  const _SeccionDestinos({
    required this.destacadosML,
    required this.cardHeight,
    required this.onDestinoTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<DestinoProvider>(
      builder: (context, dp, _) {
        final favProvider = context.watch<FavoritosProvider>();

        if (dp.listStatus == DestinoStatus.loading) {
          return SkeletonCardRow(
            count: 3,
            cardHeight: cardHeight,
            cardWidth: 180,
          );
        }

        // Fuente: API backend
        if (dp.destinos.isNotEmpty) {
          return SizedBox(
            height: cardHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: dp.destinos.length +
                  (dp.isLoadingMore ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                if (i == dp.destinos.length) {
                  return const SizedBox(
                    width: 80,
                    child: Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF2E7D32)),
                    ),
                  );
                }
                final d = dp.destinos[i];
                final esFav = favProvider.esFavorito(
                    FavoritoTargetType.destination, d.id);
                return DestinoCard(
                  nombre: d.name,
                  categoria: 'Destino turístico',
                  calificacion: d.averageRating,
                  imageUrl: d.imageUrl,
                  esFavorito: esFav,
                  onTap: () => onDestinoTap(d),
                  onFavoritoTap: () => favProvider.toggleFavorito(
                    targetType: FavoritoTargetType.destination,
                    targetId: d.id,
                  ),
                );
              },
            ),
          );
        }

        // Fallback: motor ML
        if (destacadosML.isNotEmpty) {
          return SizedBox(
            height: cardHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: destacadosML.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final d = destacadosML[i];
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

        return SizedBox(
          height: cardHeight,
          child: Center(
            child: Text(
              'No hay destinos disponibles',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Card de actividad/evento ──────────────────────────────────────────────────
class _ActividadCard extends StatelessWidget {
  final Evento evento;
  const _ActividadCard({required this.evento});

  @override
  Widget build(BuildContext context) {
    final dia = _diaSemana(evento.fechaInicio.weekday);
    return SizedBox(
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
                  child: Container(color: AppColors.primaryContainer(context)),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      dia.toUpperCase(),
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
            evento.titulo,
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
    );
  }

  String _diaSemana(int weekday) {
    const dias = [
      'lunes', 'martes', 'miércoles', 'jueves',
      'viernes', 'sábado', 'domingo',
    ];
    return dias[(weekday - 1).clamp(0, 6)];
  }
}
