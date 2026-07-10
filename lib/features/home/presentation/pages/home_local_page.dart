import 'package:flutter/material.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/planifica_banner.dart';
import '../widgets/section_header.dart';
import '../widgets/destino_card.dart';
import '../widgets/restaurante_item.dart';
import '../widgets/hotel_card.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class HomeLocalPage extends StatefulWidget {
  const HomeLocalPage({super.key});

  @override
  State<HomeLocalPage> createState() => _HomeLocalPageState();
}

class _HomeLocalPageState extends State<HomeLocalPage> {
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

  @override
  Widget build(BuildContext context) {
    // ✅ MediaQuery SOLO en build()
    final mq = MediaQuery.of(context);
    final screenW = mq.size.width;
    final isTablet = screenW >= 600;
    final isLarge = screenW >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: const HomeAppBar(),
      body: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? (isLarge ? 40 : 24) : 0,
        ),
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
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 600) {
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: constraints.maxWidth >= 900 ? 3 : 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
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
                  ],
                );
              }
              return SizedBox(
                height: 210,
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
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          const SectionHeader(
            icon: Icons.restaurant_outlined,
            titulo: 'Restaurantes destacados',
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 600) {
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: const [
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
                  ],
                );
              }
              return const Column(
                children: [
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
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          const SectionHeader(
            icon: Icons.hotel_outlined,
            titulo: 'Hoteles recomendados',
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 600) {
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
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
                );
              }
              return SizedBox(
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
              );
            },
          ),
          const SizedBox(height: 100),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/chat'),
        backgroundColor: const Color(0xFF2E7D32),
        child: const Icon(Icons.smart_toy_outlined, color: Colors.white),
      ),
      bottomNavigationBar: AppBottomNav(
        navItems: AppBottomNav.items,
        currentTab: BottomNavTab.explorar,
        onTap: _onNavTap,
      ),
    );
  }
}
