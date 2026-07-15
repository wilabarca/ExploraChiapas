import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/home_app_bar.dart';
import '../widgets/planifica_banner.dart';
import '../widgets/section_header.dart';
import '../widgets/destino_card.dart';
import '../widgets/restaurante_item.dart';
import '../widgets/hotel_card.dart';
2import '../widgets/accesos_rapidos.dart';
import '../../../destinos/presentation/pages/lugar_detail_page.dart';
import '../widgets/custom_bottom_nav_bar.dart';

import '../../../destinos/presentation/pages/lugar_detail_page.dart';
import '../../../destinos/presentation/providers/destinos_provider.dart';

import '../../data/home_api_service.dart';

class HomeTuristaPage extends StatefulWidget {
  const HomeTuristaPage({super.key});

  @override
  State<HomeTuristaPage> createState() => _HomeTuristaPageState();
}

class _HomeTuristaPageState extends State<HomeTuristaPage> {
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
  int _selectedIndex = 0;

  final HomeApiService _apiService = HomeApiService();

  List<PromocionItem> _promociones = [];
  List<EventoItem> _eventos = [];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final resultados = await Future.wait([
        _apiService.fetchPromociones(),
        _apiService.fetchEventos(),
      ]);
      if (mounted) {
        setState(() {
          _promociones = resultados[0] as List<PromocionItem>;
          _eventos = resultados[1] as List<EventoItem>;
        });
      }
    } catch (_) {}
  }


      if (!mounted) {
        return;
      }

      setState(() {
        _promociones = resultados[0] as List<PromocionItem>;
        _eventos = resultados[1] as List<EventoItem>;
      });
    } catch (_) {
      // Las promociones y los eventos no bloquean la pantalla principal.
    }
  }

  void _onNavTap(int index) {
    if (index == 1) {
      Navigator.pushNamed(context, '/mapa');
      return;
    }

    if (index == 2) {
      Navigator.pushNamed(context, '/favoritos');
      return;
    }

    if (index == 3) {
      Navigator.pushNamed(context, '/perfil');
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  void _openDestinoDetail({
    required String nombre,
    required double calificacion,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LugarDetailPage(
          nombre: nombre,
          categoria: 'Destino turístico',
          calificacion: calificacion,
          imageUrl: '',
        ),
      ),
    );
  }

  static const _destinos = [
    _DestinoData(
      nombre: 'Cascadas de Agua Azul',
      categoria: 'Naturaleza',
      calificacion: 4.9,
      imageUrl:
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&q=80',
      esFavorito: true,
    ),
    _DestinoData(
      nombre: 'Zona Arqueológica Palenque',
      categoria: 'Cultura',
      calificacion: 4.8,
      imageUrl:
          'https://images.unsplash.com/photo-1518638150340-f706e86654de?w=800&q=80',
    ),
    _DestinoData(
      nombre: 'Cañón del Sumidero',
      categoria: 'Naturaleza',
      calificacion: 4.7,
      imageUrl:
          'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800&q=80',
    ),
  ];

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
    final bottomSafePadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: const HomeAppBar(),
      body: Center(
        // ConstrainedBox: evita que el contenido se estire de más en
        // pantallas grandes (tablet/desktop/web).
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: ListView(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? (isLarge ? 40 : 24) : 0,
            ),
            children: [
              const SizedBox(height: 16),
      body: ListView(
        padding: EdgeInsets.only(
          bottom: 90 + bottomSafePadding,
        ),
        children: [
          const SizedBox(height: 16),

          const PlanificaBanner(),

          const SizedBox(height: 24),

          SectionHeader(
            icon: Icons.location_on_outlined,
            titulo: 'Destinos para ti',
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
                  if (destinoProvider.listStatus ==
                      DestinoStatus.loading) {
                    return SizedBox(
                      height: cardHeight,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF2E7D32),
                        ),
                      ),
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
                        child: _DestinosError(
                          message:
                              destinoProvider.listErrorMessage ??
                              'No fue posible obtener los destinos',
                          onRetry: () {
                            destinoProvider.loadDestinos(
                              limit: 10,
                            );
                          },
                        ),
                      ),
                    );
                  }

                  if (destinoProvider.destinos.isEmpty) {
                    return SizedBox(
                      height: cardHeight,
                      child: const Center(
                        child: Text(
                          'No hay destinos disponibles',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF777777),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      itemCount: itemCount,
                      separatorBuilder: (context, index) {
                        return const SizedBox(width: 12);
                      },
                      itemBuilder: (context, index) {
                        if (index ==
                            destinoProvider.destinos.length) {
                          return const SizedBox(
                            width: 80,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          );
                        }

                        final destino =
                            destinoProvider.destinos[index];

                        return DestinoCard(
                          nombre: destino.name,
                          categoria: 'Destino turístico',
                          calificacion:
                              destino.averageRating,
                          imageUrl: null,
                          esFavorito: false,
                          onTap: () {
                            _openDestinoDetail(
                              nombre: destino.name,
                              calificacion:
                                  destino.averageRating,
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),

          const SizedBox(height: 8),

          const AccesosRapidos(),

          const SizedBox(height: 24),

          if (_promociones.isNotEmpty) ...[
            const SectionHeader(
              icon: Icons.local_offer_outlined,
              titulo: 'Promociones activas',
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 130,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _promociones.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final promo = _promociones[index];
                  return _PromocionCard(promo: promo);
                },
              ),
            ),
            const SizedBox(height: 24),
          ],

          if (_eventos.isNotEmpty) ...[
            const SectionHeader(
              icon: Icons.event_outlined,
              titulo: 'Próximos eventos',
            ),
            const SizedBox(height: 14),
            ..._eventos.map((evento) => _EventoItem(evento: evento)),
            const SizedBox(height: 24),
          ],

          const SectionHeader(
            icon: Icons.restaurant_outlined,
            titulo: 'Restaurantes destacados',
          ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                itemCount: _promociones.length,
                separatorBuilder: (context, index) {
                  return const SizedBox(width: 12);
                },
                itemBuilder: (context, index) {
                  final promo = _promociones[index];

                  return _PromocionCard(
                    promo: promo,
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],

          if (_eventos.isNotEmpty) ...[
            const SectionHeader(
              icon: Icons.event_outlined,
              titulo: 'Próximos eventos',
            ),
            const SizedBox(height: 14),
            ..._eventos.map(
              (evento) => _EventoItem(
                evento: evento,
              ),
            ),
            const SizedBox(height: 24),
          ],

              // ── Banner "Planifica tu aventura" ──────────────────────
              const PlanificaBanner(),
              const SizedBox(height: 24),

              // ── Destinos para ti ─────────────────────────────────────
              const SectionHeader(
                icon: Icons.location_on_outlined,
                titulo: 'Destinos para ti',
                mostrarVerTodos: true,
              ),
              const SizedBox(height: 14),
              _buildDestinos(isTablet, isLarge),

              const SizedBox(height: 24),

              // ── Restaurantes destacados ──────────────────────────────
              const SectionHeader(
                icon: Icons.restaurant_outlined,
                titulo: 'Restaurantes destacados',
              ),
              const SizedBox(height: 14),
              _buildRestaurantes(isTablet),
          const RestauranteItem(
            nombre: 'El Fogón de Jovel',
            calificacion: 4.7,
            distanciaKm: 2.4,
            descripcion:
                'Especialidad en cocina de autor regional.',
            imageUrl:
                'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400&q=80',
          ),

          const RestauranteItem(
            nombre: 'Café Maya Luxury',
            calificacion: 4.9,
            distanciaKm: 0.8,
            descripcion:
                'El mejor café de altura de San Cristóbal.',
            imageUrl:
                'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400&q=80',
          ),

              const SizedBox(height: 24),

          const SectionHeader(
            icon: Icons.hotel_outlined,
            titulo: 'Hoteles recomendados',
          ),

          const SizedBox(height: 14),
              // ── Hoteles recomendados ─────────────────────────────────
              const SectionHeader(
                icon: Icons.hotel_outlined,
                titulo: 'Hoteles recomendados',
              ),
              const SizedBox(height: 14),
              _buildHoteles(isTablet, isLarge),

              const SizedBox(height: 100),
            ],
          SizedBox(
            height: 200,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              children: const [
                HotelCard(
                  nombre: 'Selva Verde Eco-Resort',
                  precioPorNoche: 2400.0,
                  imageUrl:
                      'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=400&q=80',
                ),
                HotelCard(
                  nombre: 'Boutique Casa Lum',
                  precioPorNoche: 3100.0,
                  imageUrl:
                      'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=400&q=80',
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/chat');
        },
        backgroundColor: const Color(0xFF2E7D32),
        child: const Icon(
          Icons.smart_toy_outlined,
          color: Colors.white,
        ),
      ),
      // 🔒 Bottom nav SIN CAMBIOS, tal como pediste.
      bottomNavigationBar: AppBottomNav(
        navItems: AppBottomNav.items,
        currentTab: BottomNavTab.explorar,
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
      ),
    );
  }

  /// "Destinos para ti"
  /// - Móvil: scroll horizontal con FractionallySizedBox + ConstrainedBox.
  /// - Tablet/Desktop: Wrap, para que las tarjetas fluyan según el ancho.
  Widget _buildDestinos(bool isTablet, bool isLarge) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;

        if (isTablet) {
          final widthFactor = isLarge ? 1 / 3 : 1 / 2;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: _destinos.map((d) {
                return ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth - 40),
                  child: FractionallySizedBox(
                    widthFactor: widthFactor,
                    child: AspectRatio(
                      aspectRatio: 0.95,
                      child: DestinoCard(
                        nombre: d.nombre,
                        categoria: d.categoria,
                        calificacion: d.calificacion,
                        imageUrl: d.imageUrl,
                        esFavorito: d.esFavorito,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }

        return SizedBox(
          height: 210,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _destinos.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final d = _destinos[index];
              return ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: FractionallySizedBox(
                  widthFactor: 0.58,
                  child: DestinoCard(
                    nombre: d.nombre,
                    categoria: d.categoria,
                    calificacion: d.calificacion,
                    imageUrl: d.imageUrl,
                    esFavorito: d.esFavorito,
}

class _DestinosError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _DestinosError({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFCDD2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 36,
            color: Color(0xFFD32F2F),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(
              Icons.refresh,
              size: 18,
            ),
            label: const Text('Reintentar'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }
}

class _PromocionCard extends StatelessWidget {
  final PromocionItem promo;

  const _PromocionCard({
    required this.promo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE8F5E9),
        ),
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
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_offer,
                size: 16,
                color: Color(0xFF2E7D32),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  promo.titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B1B1B),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// "Restaurantes destacados"
  Widget _buildRestaurantes(bool isTablet) {
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
              (r) => RestauranteItem(
                nombre: r.nombre,
                calificacion: r.calificacion,
                distanciaKm: r.distanciaKm,
                descripcion: r.descripcion,
                imageUrl: r.imageUrl,
          if (promo.negocioNombre != null) ...[
            const SizedBox(height: 6),
            Text(
              promo.negocioNombre!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF666666),
              ),
            ),
          ],
          if (promo.descripcion != null) ...[
            const SizedBox(height: 6),
            Text(
              promo.descripcion!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF888888),
              ),
            ),
          ],
          const Spacer(),
          if (promo.precio != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(8),
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
              (r) => RestauranteItem(
                nombre: r.nombre,
                calificacion: r.calificacion,
                distanciaKm: r.distanciaKm,
                descripcion: r.descripcion,
                imageUrl: r.imageUrl,
              ),
            )
            .toList(),
      ),
    );
  }

  /// "Hoteles recomendados"
  Widget _buildHoteles(bool isTablet, bool isLarge) {
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
                  (h) => HotelCard(
                    nombre: h.nombre,
                    precioPorNoche: h.precioPorNoche,
                    imageUrl: h.imageUrl,
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
                  child: HotelCard(
                    nombre: h.nombre,
                    precioPorNoche: h.precioPorNoche,
                    imageUrl: h.imageUrl,
}

class _EventoItem extends StatelessWidget {
  final EventoItem evento;

  const _EventoItem({
    required this.evento,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 6,
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
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
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.event,
                color: Color(0xFF2E7D32),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    evento.titulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B1B1B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 12,
                        color: Color(0xFF888888),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        evento.fechaInicio,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF888888),
                        ),
                      ),
                      if (evento.municipio != null) ...[
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.place_outlined,
                          size: 12,
                          color: Color(0xFF888888),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            evento.municipio!,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF888888),
                            ),
                          ),
                        ),
                      ],
                    ],
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

class _DestinoData {
  final String nombre;
  final String categoria;
  final double calificacion;
  final String imageUrl;
  final bool esFavorito;

  const _DestinoData({
    required this.nombre,
    required this.categoria,
    required this.calificacion,
    required this.imageUrl,
    this.esFavorito = false,
  });
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8F5E9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_offer,
                size: 16,
                color: Color(0xFF2E7D32),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  promo.titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B1B1B),
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
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF666666),
              ),
            ),
          ],
          if (promo.descripcion != null) ...[
            const SizedBox(height: 6),
            Text(
              promo.descripcion!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF888888),
              ),
            ),
          ],
          const Spacer(),
          if (promo.precio != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '\$${promo.precio!.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EventoItem extends StatelessWidget {
  final EventoItem evento;

  const _EventoItem({required this.evento});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.event,
                color: Color(0xFF2E7D32),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    evento.titulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B1B1B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 12,
                        color: Color(0xFF888888),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        evento.fechaInicio,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF888888),
                        ),
                      ),
                      if (evento.municipio != null) ...[
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.place_outlined,
                          size: 12,
                          color: Color(0xFF888888),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            evento.municipio!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF888888),
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
