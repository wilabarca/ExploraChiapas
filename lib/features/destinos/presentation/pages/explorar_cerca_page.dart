import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../home/presentation/widgets/home_app_bar.dart';
import '../../../home/presentation/widgets/custom_bottom_nav_bar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import 'lugares_cercanos_page.dart';
import 'rutas_urbanas_page.dart';

// Imágenes decorativas de categoría — mismas URLs ya usadas en el resto
// de la app (interests_page.dart, home_remote_datasource.dart) para
// Naturaleza/Cultura, reaprovechadas aquí en vez de introducir nuevas.
const String _imgDescubrimiento =
    'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=1000&q=80';
const String _imgRutasUrbanas =
    'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=1000&q=80';
const String _imgRecomendar =
    'https://images.unsplash.com/photo-1518638150340-f706e86654de?w=1000&q=80';

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

  void _irALugaresCercanos() => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const LugaresCercanosPage()),
  );

  void _irARecomendar() => Navigator.pushNamed(context, '/recomendar');

  void _irARutasUrbanas() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RutasUrbanasPage()),
    );
  }

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
                              child: _DescubrimientoCard(
                                onVerMapa: _irALugaresCercanos,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _RutasUrbanasCard(
                                onExplorar: _irARutasUrbanas,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _DescubrimientoCard(onVerMapa: _irALugaresCercanos),
                            const SizedBox(height: 16),
                            _RutasUrbanasCard(onExplorar: _irARutasUrbanas),
                          ],
                        ),
                ),

                const SizedBox(height: 16),

                FadeSlideIn(
                  delay: const Duration(milliseconds: 140),
                  child: _RecomendarLugarCard(onSugerir: _irARecomendar),
                ),

                const SizedBox(height: 40),
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

// ── Tarjeta base compartida: foto de fondo + degradado + ripple ───────────
// Reutilizada por las tres tarjetas principales para no duplicar la
// estructura Container(sombra)+Material+InkWell+Stack(foto+degradado).
class _TarjetaImagenDegradada extends StatelessWidget {
  final String imageUrl;
  final List<Color> overlay;
  final VoidCallback onTap;
  final Widget child;

  const _TarjetaImagenDegradada({
    required this.imageUrl,
    required this.overlay,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return _PressableScale(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: AppColors.isDark(context) ? 0.4 : 0.16,
              ),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            splashColor: Colors.white.withValues(alpha: 0.14),
            highlightColor: Colors.white.withValues(alpha: 0.06),
            // Sin StackFit.expand: dentro de un Column normal (sin
            // Expanded) la altura entrante es infinita, y expandir el
            // Stack a eso hace crashear el layout (pantalla en blanco en
            // vez del típico overlay rojo). En su lugar, el contenido
            // real (texto + botón) fija la altura mediante su propio
            // ConstrainedBox, y las capas de foto/degradado la igualan
            // con Positioned.fill — así el Stack se dimensiona de forma
            // acotada y natural.
            child: Stack(
              children: [
                Positioned.fill(child: _FotoDeCategoria(url: imageUrl)),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: overlay,
                      ),
                    ),
                  ),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 200),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Foto de categoría con cache + shimmer mientras carga ───────────────────
class _FotoDeCategoria extends StatelessWidget {
  final String url;

  const _FotoDeCategoria({required this.url});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      fadeInDuration: const Duration(milliseconds: 280),
      placeholder: (_, __) => const _ShimmerVerde(),
      errorWidget: (_, __, ___) =>
          Container(color: AppColors.primaryContainer(context)),
    );
  }
}

/// Placeholder tipo shimmer (pulso suave entre dos tonos de verde) para
/// no mostrar un cuadro sólido/plano mientras la imagen de red carga.
class _ShimmerVerde extends StatefulWidget {
  const _ShimmerVerde();

  @override
  State<_ShimmerVerde> createState() => _ShimmerVerdeState();
}

class _ShimmerVerdeState extends State<_ShimmerVerde>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return ColoredBox(
          color: Color.lerp(
            const Color(0xFF1B4332),
            const Color(0xFF2E7D32),
            _ctrl.value,
          )!,
        );
      },
    );
  }
}

// ── Envoltura reutilizable: reduce ligeramente de tamaño al presionar ─────
// Aporta retroalimentación táctil (además del ripple de InkWell) en las
// tarjetas principales de esta pantalla.
class _PressableScale extends StatefulWidget {
  final Widget child;

  const _PressableScale({required this.child});

  @override
  State<_PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<_PressableScale> {
  bool _presionado = false;

  void _setPresionado(bool valor) {
    if (_presionado != valor) setState(() => _presionado = valor);
  }

  @override
  Widget build(BuildContext context) {
    // Solo reacciona a la presión para el efecto visual — el tap en sí
    // (navegación) lo sigue resolviendo el InkWell interno, que ya trae
    // su propio ripple y soporte de accesibilidad.
    return Listener(
      onPointerDown: (_) => _setPresionado(true),
      onPointerUp: (_) => _setPresionado(false),
      onPointerCancel: (_) => _setPresionado(false),
      child: AnimatedScale(
        scale: _presionado ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
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
    final oscuro = Color.lerp(base, Colors.black, 0.35)!;

    return _TarjetaImagenDegradada(
      imageUrl: _imgDescubrimiento,
      overlay: [
        Colors.black.withValues(alpha: 0.1),
        base.withValues(alpha: 0.72),
        oscuro.withValues(alpha: 0.93),
      ],
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
            'Busca destinos reales en un radio ajustable alrededor de '
            'tu ubicación actual, ordenados por distancia.',
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
                      'Buscar cerca de mí',
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
class _RutasUrbanasCard extends StatelessWidget {
  final VoidCallback onExplorar;

  const _RutasUrbanasCard({required this.onExplorar});

  @override
  Widget build(BuildContext context) {
    // Verde-azulado (teal) para diferenciarla de las otras dos tarjetas
    // sin salirse de la paleta de tonos naturales de la app.
    const tealOscuro = Color(0xFF0D4F45);
    const tealClaro = Color(0xFF1F7A68);

    return _TarjetaImagenDegradada(
      imageUrl: _imgRutasUrbanas,
      overlay: [
        Colors.black.withValues(alpha: 0.1),
        tealClaro.withValues(alpha: 0.68),
        tealOscuro.withValues(alpha: 0.92),
      ],
      onTap: onExplorar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const _EtiquetaCategoria(
            icon: Icons.directions_walk_outlined,
            texto: 'CAMINATA',
            color: Colors.white70,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('🥾', style: TextStyle(fontSize: 18)),
              SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Rutas Urbanas',
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
            'Micro-aventuras culturales diseñadas para recorrer a '
            'pie. Conecta con la esencia de la ciudad.',
            style: TextStyle(fontSize: 13, color: Colors.white70, height: 1.4),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onExplorar,
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
                      'Explorar rutas',
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

// ── Card "Recomendar Lugar" (Colaboración) ─────────────────────────────────
class _RecomendarLugarCard extends StatelessWidget {
  final VoidCallback onSugerir;
  const _RecomendarLugarCard({required this.onSugerir});

  @override
  Widget build(BuildContext context) {
    final base = AppColors.primary(context);
    final oscuro = Color.lerp(base, Colors.black, 0.55)!;

    return _TarjetaImagenDegradada(
      imageUrl: _imgRecomendar,
      overlay: [
        oscuro.withValues(alpha: 0.55),
        oscuro.withValues(alpha: 0.88),
        oscuro.withValues(alpha: 0.96),
      ],
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
