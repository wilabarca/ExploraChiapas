import 'package:flutter/material.dart';
import '../../../home/presentation/widgets/home_app_bar.dart';
import '../../../home/presentation/widgets/custom_bottom_nav_bar.dart';

class ExplorarCercaPage extends StatefulWidget {
  const ExplorarCercaPage({super.key});

  @override
  State<ExplorarCercaPage> createState() => _ExplorarCercaPageState();
}

class _ExplorarCercaPageState extends State<ExplorarCercaPage> {
  void _onNavTap(BottomNavTab tab) {
    switch (tab) {
      case BottomNavTab.explorar:
        Navigator.popUntil(context, (route) => route.isFirst);
        break;
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
    }
  }

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
          constraints: const BoxConstraints(maxWidth: 900),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? (isLarge ? 40 : 24) : 20,
              vertical: 20,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Encabezado ─────────────────────────────────────
                    Text(
                      'Explorar cerca de mí',
                      style: TextStyle(
                        fontSize: isTablet ? 32 : 26,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1B5E20),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Descubre la magia de Chiapas que late a solo unos '
                      'pasos de tu ubicación. Tesoros ocultos, rutas urbanas '
                      'y experiencias locales te esperan.',
                      style: TextStyle(
                        fontSize: isTablet ? 15 : 13.5,
                        color: const Color(0xFF666666),
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Cards principales ────────────────────────────────
                    // Tablet/Desktop: Wrap en 2 columnas.
                    // Móvil: columna vertical (Column simple).
                    isTablet
                        ? Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: [
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: (constraints.maxWidth - 16) / 2,
                                ),
                                child: _DescubrimientoCard(
                                  onVerMapa: () =>
                                      Navigator.pushNamed(context, '/mapa'),
                                ),
                              ),
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: (constraints.maxWidth - 16) / 2,
                                ),
                                child: const _RutasUrbanasCard(),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              _DescubrimientoCard(
                                onVerMapa: () =>
                                    Navigator.pushNamed(context, '/mapa'),
                              ),
                              const SizedBox(height: 16),
                              const _RutasUrbanasCard(),
                            ],
                          ),

                    const SizedBox(height: 16),

                    // ── Card Recomendar Lugar ────────────────────────────
                    // FractionallySizedBox: ocupa el 100% del ancho disponible.
                    FractionallySizedBox(
                      widthFactor: 1.0,
                      child: _RecomendarLugarCard(
                        onSugerir: () =>
                            Navigator.pushNamed(context, '/recomendar'),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Sello "Curaduría Experta" ────────────────────────
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.verified_outlined,
                              size: 15,
                              color: Color(0xFF2E7D32),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Curaduría Experta',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Center(
                      child: Text(
                        'Tu aventura comienza aquí',
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 15,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1B1B1B),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 380),
                        child: Text(
                          'Cada destino y ruta ha sido seleccionado para '
                          'ofrecerte una experiencia auténtica y sostenible '
                          'en el corazón de la selva y sus ciudades.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 12.5,
                            color: const Color(0xFF888888),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                );
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        navItems: AppBottomNav.items,
        currentTab: BottomNavTab.explorar,
        onTap: _onNavTap,
      ),
    );
  }
}

// ── Card "Lugares cercanos" (Descubrimiento) ──────────────────────────────
class _DescubrimientoCard extends StatelessWidget {
  final VoidCallback onVerMapa;
  const _DescubrimientoCard({required this.onVerMapa});

  @override
  Widget build(BuildContext context) {
    // AspectRatio: mantiene proporción de la tarjeta sin importar el ancho.
    return AspectRatio(
      aspectRatio: 0.92,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4A7C6F), Color(0xFF6B9B8F)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -10,
              child: Icon(
                Icons.map_outlined,
                size: 130,
                color: Colors.white.withOpacity(0.12),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.location_on_outlined,
                          color: Colors.white70,
                          size: 14,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'DESCUBRIMIENTO',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white70,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('📍', style: TextStyle(fontSize: 18)),
                        SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Lugares cercanos',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Visualiza un mapa interactivo con los destinos más '
                      'fascinantes y servicios esenciales a tu alrededor.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
                // FractionallySizedBox: el botón ocupa todo el ancho disponible.
                FractionallySizedBox(
                  widthFactor: 1.0,
                  child: ElevatedButton(
                    onPressed: onVerMapa,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'Ver mapa y lista',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Card "Rutas Urbanas" (Caminata) ────────────────────────────────────────
class _RutasUrbanasCard extends StatelessWidget {
  const _RutasUrbanasCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AspectRatio: imagen con proporción fija.
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(
              'https://images.unsplash.com/photo-1518638150340-f706e86654de?w=800&q=80',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: const Color(0xFFD8F5D8)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.directions_walk_outlined,
                      size: 14,
                      color: Color(0xFF2E7D32),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'CAMINATA',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2E7D32),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  '🥾 Rutas Urbanas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B1B1B),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Micro-aventuras culturales diseñadas para recorrer a '
                  'pie. Conecta con la esencia de la ciudad.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF666666),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                // FractionallySizedBox: botón outline a todo lo ancho.
                FractionallySizedBox(
                  widthFactor: 1.0,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFF2E7D32)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Explorar rutas',
                      style: TextStyle(
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Card "Recomendar Lugar" (Colaboración) ─────────────────────────────────
class _RecomendarLugarCard extends StatelessWidget {
  final VoidCallback onSugerir;
  const _RecomendarLugarCard({required this.onSugerir});

  @override
  Widget build(BuildContext context) {
    // GestureDetector: toda la tarjeta es tappable, no solo el botón.
    return GestureDetector(
      onTap: onSugerir,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color(0xFF1B5E20),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -16,
              bottom: -16,
              child: Icon(
                Icons.add_location_alt_outlined,
                size: 110,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.add_circle_outline,
                      color: Colors.white70,
                      size: 14,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'COLABORACIÓN',
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.add, color: Colors.white, size: 20),
                    SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Recomendar Lugar',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '¿Conoces un rincón especial que no está en nuestro '
                  'mapa? Ayúdanos a crecer la comunidad sugiriendo nuevos '
                  'destinos en Chiapas.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                // Row + Expanded: el botón crece pero deja aire alrededor.
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onSugerir,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.15),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              'Sugerir nuevo sitio',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(
                              Icons.edit_outlined,
                              color: Colors.white,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
