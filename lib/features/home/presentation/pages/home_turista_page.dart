import 'package:flutter/material.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/planifica_banner.dart';
import '../widgets/section_header.dart';
import '../widgets/destino_card.dart';
import '../widgets/restaurante_item.dart';
import '../widgets/hotel_card.dart';
import '../widgets/custom_bottom_nav_bar.dart';

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
    }
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

              const SizedBox(height: 24),

              // ── Hoteles recomendados ─────────────────────────────────
              const SectionHeader(
                icon: Icons.hotel_outlined,
                titulo: 'Hoteles recomendados',
              ),
              const SizedBox(height: 14),
              _buildHoteles(isTablet, isLarge),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/chat'),
        backgroundColor: const Color(0xFF2E7D32),
        child: const Icon(Icons.smart_toy_outlined, color: Colors.white),
      ),
      // 🔒 Bottom nav SIN CAMBIOS, tal como pediste.
      bottomNavigationBar: AppBottomNav(
        navItems: AppBottomNav.items,
        currentTab: BottomNavTab.explorar,
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
