import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/home_app_bar.dart';
import '../widgets/planifica_banner.dart';
import '../widgets/section_header.dart';
import '../widgets/destino_card.dart';
import '../widgets/restaurante_item.dart';
import '../widgets/hotel_card.dart';
import '../widgets/accesos_rapidos.dart';
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
  int _selectedIndex = 0;

  final HomeApiService _apiService = HomeApiService();

  List<PromocionItem> _promociones = [];
  List<EventoItem> _eventos = [];

  @override
  void initState() {
    super.initState();

    _cargarDatos();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final destinoProvider = context.read<DestinoProvider>();

      if (destinoProvider.listStatus == DestinoStatus.idle) {
        destinoProvider.loadDestinos(limit: 10);
      }
    });
  }

  Future<void> _cargarDatos() async {
    try {
      final resultados = await Future.wait([
        _apiService.fetchPromociones(),
        _apiService.fetchEventos(),
      ]);

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

  @override
  Widget build(BuildContext context) {
    final bottomSafePadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: const HomeAppBar(),
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

          const SectionHeader(
            icon: Icons.restaurant_outlined,
            titulo: 'Restaurantes destacados',
          ),

          const SizedBox(height: 14),

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

          const SizedBox(height: 20),
        ],
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
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
      ),
    );
  }
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
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}