import 'package:flutter/material.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/planifica_banner.dart';
import '../widgets/section_header.dart';
import '../widgets/destino_card.dart';
import '../widgets/restaurante_item.dart';
import '../widgets/hotel_card.dart';
import '../widgets/accesos_rapidos.dart';
import '../../../destinos/presentation/pages/lugar_detail_page.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: const HomeAppBar(),
      body: ListView(
        children: [
          const SizedBox(height: 16),

          const PlanificaBanner(),

          const SizedBox(height: 24),

          SectionHeader(
            icon: Icons.location_on_outlined,
            titulo: 'Destinos para ti',
            mostrarVerTodos: true,
            onVerTodos: () {},
          ),

          const SizedBox(height: 14),

          SizedBox(
            height: 210,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                DestinoCard(
                  nombre: 'Cascadas de Agua Azul',
                  categoria: 'Naturaleza',
                  calificacion: 4.9,
                  imageUrl:
                      'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&q=80',
                  esFavorito: true,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LugarDetailPage(
                        nombre: 'Cascadas de Agua Azul',
                        categoria: 'Naturaleza',
                        calificacion: 4.9,
                        imageUrl:
                            'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&q=80',
                      ),
                    ),
                  ),
                ),
                DestinoCard(
                  nombre: 'Zona Arqueológica Palenque',
                  categoria: 'Cultura',
                  calificacion: 4.8,
                  imageUrl:
                      'https://images.unsplash.com/photo-1518638150340-f706e86654de?w=800&q=80',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LugarDetailPage(
                        nombre: 'Zona Arqueológica Palenque',
                        categoria: 'Cultura',
                        calificacion: 4.8,
                        imageUrl:
                            'https://images.unsplash.com/photo-1518638150340-f706e86654de?w=800&q=80',
                      ),
                    ),
                  ),
                ),
                DestinoCard(
                  nombre: 'Cañón del Sumidero',
                  categoria: 'Naturaleza',
                  calificacion: 4.7,
                  imageUrl:
                      'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800&q=80',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LugarDetailPage(
                        nombre: 'Cañón del Sumidero',
                        categoria: 'Naturaleza',
                        calificacion: 4.7,
                        imageUrl:
                            'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800&q=80',
                      ),
                    ),
                  ),
                ),
              ],
            ),
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

          const SizedBox(height: 14),

          RestauranteItem(
            nombre: 'El Fogón de Jovel',
            calificacion: 4.7,
            distanciaKm: 2.4,
            descripcion: 'Especialidad en cocina de autor regional.',
            imageUrl:
                'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400&q=80',
          ),

          RestauranteItem(
            nombre: 'Café Maya Luxury',
            calificacion: 4.9,
            distanciaKm: 0.8,
            descripcion: 'El mejor café de altura de San Cristóbal.',
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
              padding: const EdgeInsets.symmetric(horizontal: 20),
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

          const SizedBox(height: 100),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/chat'),
        backgroundColor: const Color(0xFF2E7D32),
        child: const Icon(Icons.smart_toy_outlined, color: Colors.white),
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2E7D32),
        unselectedItemColor: const Color(0xFF999999),
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, '/mapa');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/favoritos');
          } else if (index == 3) {
            Navigator.pushNamed(context, '/perfil');
          } else {
            setState(() => _selectedIndex = index);
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
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
