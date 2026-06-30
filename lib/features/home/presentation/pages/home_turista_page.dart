import 'package:flutter/material.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/planifica_banner.dart';
import '../widgets/section_header.dart';
import '../widgets/destino_card.dart';
import '../widgets/restaurante_item.dart';
import '../widgets/hotel_card.dart';
import '../widgets/accesos_rapidos.dart';
import '../../../profile/presentation/pages/profile_page.dart';

class HomeTuristaPage extends StatefulWidget {
  const HomeTuristaPage({super.key});

  @override
  State<HomeTuristaPage> createState() => _HomeTuristaPageState();
}

class _HomeTuristaPageState extends State<HomeTuristaPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: const HomeAppBar(),
      body: ListView(
        children: [
          const SizedBox(height: 16),

          // Banner planifica
          const PlanificaBanner(),

          const SizedBox(height: 24),

          // Destinos para ti
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

          const SizedBox(height: 8),

          // Accesos rápidos
          const AccesosRapidos(),

          const SizedBox(height: 24),

          // Restaurantes destacados
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

          // Hoteles recomendados
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
          if (index == 3) {
            // Tab Perfil - navega a la pantalla de perfil
            Navigator.pushNamed(context, '/perfil');
          } else {
            // Para los otros tabs, actualiza el índice seleccionado
            setState(() {
              _selectedIndex = index;
            });
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
