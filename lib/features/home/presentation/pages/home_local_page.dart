import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/section_header.dart';
import '../widgets/destino_card.dart';
import '../widgets/restaurante_item.dart';
import '../widgets/hotel_card.dart';
import '../widgets/eventos_banner.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../../../../core/theme/app_colors.dart';

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
        break; // ya estamos aquí
    }
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

          // ── Destinos para ti ───────────────────────────────────────────
          SectionHeader(
            icon: Icons.place_outlined,
            titulo: 'Destinos para ti',
            mostrarVerTodos: true,
            onVerTodos: () {},
          ),
          const SizedBox(height: 14),
          SizedBox(
            // ✓ AspectRatio implícito — altura proporcional a la pantalla
            height: size.height * 0.26,
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

          const SizedBox(height: 24),

          // ── Módulo de descubrimiento ───────────────────────────────────
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
                              Icon(
                                Icons.explore_outlined,
                                color: Colors.white70,
                                size: 14,
                              ),
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
                            'Encuentra rutas urbanas, lugares cercanos y sugerencias personalizadas.',
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
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.near_me,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── 🔥 Promociones ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _PromocionesBanner(onTap: _irAPromociones),
          ),

          const SizedBox(height: 24),

          // ── Restaurantes destacados ────────────────────────────────────
          SectionHeader(
            icon: Icons.restaurant_outlined,
            titulo: 'Restaurantes destacados',
            mostrarVerTodos: true,
            onVerTodos: () => _irANegocios('restaurante', 'Restaurantes'),
          ),
          const SizedBox(height: 14),

          GestureDetector(
            onTap: () => _irANegocios('restaurante', 'Restaurantes'),
            child: RestauranteItem(
              nombre: 'El Fogón de Jovel',
              calificacion: 4.7,
              distanciaKm: 2.4,
              descripcion: 'Especialidad en cocina de autor regional.',
              imageUrl:
                  'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400&q=80',
            ),
          ),
          GestureDetector(
            onTap: () => _irANegocios('restaurante', 'Restaurantes'),
            child: RestauranteItem(
              nombre: 'Café Maya Luxury',
              calificacion: 4.9,
              distanciaKm: 0.8,
              descripcion: 'El mejor café de altura de San Cristóbal.',
              imageUrl:
                  'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400&q=80',
            ),
          ),

          const SizedBox(height: 24),

          // ── Eventos y Actividades ──────────────────────────────────────
          SectionHeader(
            icon: Icons.calendar_today_outlined,
            titulo: 'Eventos y Actividades',
          ),
          const SizedBox(height: 14),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: EventosBanner(
              onExplorar: () => Navigator.pushNamed(context, '/eventos'),
            ),
          ),

          const SizedBox(height: 16),

          // ── Crear ruta corta local ─────────────────────────────────────
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
                      child: const Icon(
                        Icons.alt_route,
                        color: Colors.white,
                        size: 24,
                      ),
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
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppColors.primary(context),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Actividades de fin de semana — label
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'ACTIVIDADES DE FIN DE SEMANA',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary(context),
                letterSpacing: 1.1,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ✓ ListView horizontal de actividades
          SizedBox(
            height: size.height * 0.22,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _ActividadCard(
                  dia: 'SÁBADO',
                  nombre: 'Taller de Barro\nAmatenango',
                  imageUrl:
                      'https://images.unsplash.com/photo-1565193566173-7a0ee3dbe261?w=400&q=80',
                ),
                const SizedBox(width: 12),
                _ActividadCard(
                  dia: 'DOMINGO',
                  nombre: 'Senderismo Místico\nNocturno',
                  imageUrl:
                      'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=400&q=80',
                ),
                const SizedBox(width: 12),
                _ActividadCard(
                  dia: 'SÁBADO',
                  nombre: 'Cata de Café\nde Altura',
                  imageUrl:
                      'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400&q=80',
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Hoteles recomendados ───────────────────────────────────────
          SectionHeader(
            icon: Icons.hotel_outlined,
            titulo: 'Hoteles recomendados',
            mostrarVerTodos: true,
            onVerTodos: () => _irANegocios('hotel', 'Hoteles'),
          ),
          const SizedBox(height: 14),

          SizedBox(
            height: 200,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                GestureDetector(
                  onTap: () => _irANegocios('hotel', 'Hoteles'),
                  child: const HotelCard(
                    nombre: 'Selva Verde Eco-Resort',
                    precioPorNoche: 2400.0,
                    imageUrl:
                        'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=400&q=80',
                  ),
                ),
                GestureDetector(
                  onTap: () => _irANegocios('hotel', 'Hoteles'),
                  child: const HotelCard(
                    nombre: 'Boutique Casa Lum',
                    precioPorNoche: 3100.0,
                    imageUrl:
                        'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=400&q=80',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 100),
        ],
      ),
      // 🔒 Bottom nav — mismo patrón que HomeTuristaPage.
      bottomNavigationBar: AppBottomNav(
        navItems: AppBottomNav.items,
        currentTab: BottomNavTab.explorar,
        onTap: _onNavTap,
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
    // LayoutBuilder: adapta proporción y tamaños según el ancho real
    // disponible (no solo el ancho de pantalla).
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
                                  'PROMOCIONES',
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
                                'Descubre descuentos exclusivos de '
                                'hoteles, restaurantes, tours y más.',
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
                                  'Ver promociones',
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

// ── Widget de actividad de fin de semana ─────────────────────────────────────
class _ActividadCard extends StatelessWidget {
  final String dia;
  final String nombre;
  final String imageUrl;

  const _ActividadCard({
    required this.dia,
    required this.nombre,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: 150,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✓ AspectRatio para imagen proporcional
              AspectRatio(
                aspectRatio: 4 / 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            Container(color: const Color(0xFFD8F5D8)),
                        errorWidget: (_, __, ___) => Container(
                          color: const Color(0xFFD8F5D8),
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          dia,
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
              // ✓ Expanded implícito con maxLines para evitar overflow
              Text(
                nombre,
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
      },
    );
  }
}
