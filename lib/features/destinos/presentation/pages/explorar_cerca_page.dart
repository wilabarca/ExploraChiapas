import 'package:flutter/material.dart';
import '../../../home/presentation/widgets/home_app_bar.dart';
import '../../../home/presentation/widgets/custom_bottom_nav_bar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/fade_slide_in.dart';

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

  void _irAMapa() => Navigator.pushNamed(context, '/mapa');

  void _irARecomendar() => Navigator.pushNamed(context, '/recomendar');

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenW = mq.size.width;
    final isTablet = screenW >= 600;
    final isLarge = screenW >= 900;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: const HomeAppBar(),
      body: Center(
        // ConstrainedBox: evita que el contenido se estire de más en
        // pantallas grandes (tablet/desktop/web).
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? (isLarge ? 40 : 24) : 20,
              vertical: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FadeSlideIn(child: _Encabezado()),

                const SizedBox(height: 28),

                // Tablet/Desktop: dos columnas lado a lado.
                // Móvil: apiladas en columna.
                FadeSlideIn(
                  delay: const Duration(milliseconds: 80),
                  child: isTablet
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _DescubrimientoCard(onVerMapa: _irAMapa),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(child: _RutasUrbanasCard()),
                          ],
                        )
                      : Column(
                          children: [
                            _DescubrimientoCard(onVerMapa: _irAMapa),
                            const SizedBox(height: 16),
                            const _RutasUrbanasCard(),
                          ],
                        ),
                ),

                const SizedBox(height: 16),

                FadeSlideIn(
                  delay: const Duration(milliseconds: 140),
                  child: _RecomendarLugarCard(onSugerir: _irARecomendar),
                ),

                const SizedBox(height: 36),

                FadeSlideIn(
                  delay: const Duration(milliseconds: 200),
                  child: const _CuraduriaFooter(),
                ),

                const SizedBox(height: 100),
              ],
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

// ── Encabezado ────────────────────────────────────────────────────────────
class _Encabezado extends StatelessWidget {
  const _Encabezado();

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).width >= 600;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Explorar cerca de mí',
          style: TextStyle(
            fontSize: isTablet ? 32 : 26,
            fontWeight: FontWeight.bold,
            color: AppColors.primary(context),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Descubre la magia de Chiapas que late a solo unos '
          'pasos de tu ubicación. Tesoros ocultos, rutas urbanas '
          'y experiencias locales te esperan.',
          style: TextStyle(
            fontSize: isTablet ? 15 : 13.5,
            color: AppColors.textSecondary(context),
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

// ── Tarjeta base compartida: gradiente + marca de agua + ripple ───────────
// Reutilizada por las dos tarjetas "de marca" (Descubrimiento y
// Recomendar Lugar) para no duplicar la estructura Material+InkWell+Stack.
class _TarjetaDegradada extends StatelessWidget {
  final List<Color> colores;
  final IconData iconoMarcaAgua;
  final VoidCallback onTap;
  final Widget child;

  const _TarjetaDegradada({
    required this.colores,
    required this.iconoMarcaAgua,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colores,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -10,
                child: Icon(
                  iconoMarcaAgua,
                  size: 130,
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

// ── Etiqueta pequeña tipo "DESCUBRIMIENTO" / "COLABORACIÓN" ───────────────
class _EtiquetaCategoria extends StatelessWidget {
  final IconData icon;
  final String texto;
  final Color color;

  const _EtiquetaCategoria({
    required this.icon,
    required this.texto,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            texto,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Card "Lugares cercanos" (Descubrimiento) ──────────────────────────────
class _DescubrimientoCard extends StatelessWidget {
  final VoidCallback onVerMapa;
  const _DescubrimientoCard({required this.onVerMapa});

  @override
  Widget build(BuildContext context) {
    final base = AppColors.primary(context);
    final oscuro = Color.lerp(base, Colors.black, 0.2)!;

    return _TarjetaDegradada(
      colores: [base, oscuro],
      iconoMarcaAgua: Icons.map_outlined,
      onTap: onVerMapa,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const _EtiquetaCategoria(
            icon: Icons.location_on_outlined,
            texto: 'DESCUBRIMIENTO',
            color: Colors.white70,
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
            style: TextStyle(fontSize: 13, color: Colors.white70, height: 1.4),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onVerMapa,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.18),
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
                  Flexible(
                    child: Text(
                      'Ver mapa y lista',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Card "Rutas Urbanas" (Caminata) ────────────────────────────────────────
// Tarjeta plana y minimalista (sin foto de stock): reduce peticiones de
// red en esta pantalla y se alinea con el lenguaje visual de referencia.
class _RutasUrbanasCard extends StatelessWidget {
  const _RutasUrbanasCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer(context),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _EtiquetaCategoria(
            icon: Icons.directions_walk_outlined,
            texto: 'CAMINATA',
            color: AppColors.onPrimaryContainer(context),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🥾', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Rutas Urbanas',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onPrimaryContainer(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Micro-aventuras culturales diseñadas para recorrer a '
            'pie. Conecta con la esencia de la ciudad.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.onPrimaryContainer(
                context,
              ).withValues(alpha: 0.75),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              // Sin destino todavía: se conserva el mismo comportamiento
              // (sin acción) que tenía el botón original.
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: AppColors.primary(context)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'Explorar rutas',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.primary(context),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
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
    final base = AppColors.primary(context);
    final oscuro = Color.lerp(base, Colors.black, 0.4)!;

    return _TarjetaDegradada(
      colores: [oscuro, oscuro],
      iconoMarcaAgua: Icons.add_location_alt_outlined,
      onTap: onSugerir,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const _EtiquetaCategoria(
            icon: Icons.add_circle_outline,
            texto: 'COLABORACIÓN',
            color: Colors.white70,
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
            style: TextStyle(fontSize: 13, color: Colors.white70, height: 1.4),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSugerir,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.15),
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
                  Flexible(
                    child: Text(
                      'Sugerir nuevo sitio',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.edit_outlined, color: Colors.white, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sello "Curaduría Experta" + mensaje de cierre ──────────────────────────
class _CuraduriaFooter extends StatelessWidget {
  const _CuraduriaFooter();

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).width >= 600;
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer(context),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_outlined,
                  size: 15,
                  color: AppColors.onPrimaryContainer(context),
                ),
                const SizedBox(width: 6),
                Text(
                  'Curaduría Experta',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onPrimaryContainer(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tu aventura comienza aquí',
            style: TextStyle(
              fontSize: isTablet ? 18 : 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Text(
              'Cada destino y ruta ha sido seleccionado para '
              'ofrecerte una experiencia auténtica y sostenible '
              'en el corazón de la selva y sus ciudades.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isTablet ? 14 : 12.5,
                color: AppColors.textSecondary(context),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
