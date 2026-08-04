import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/services/avatar/avatar_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../profile/domain/entities/perfil_entity.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

const String _logoAsset = 'assets/images/iconoapp.jpg';

/// Header compartido de la app. Por defecto es la barra compacta de
/// siempre (usada en ~10 pantallas internas: perfil, favoritos,
/// promociones, reseñas, etc. — no se tocó su diseño para no arrastrar
/// cambios a pantallas que no pidieron rediseño). Con [esPantallaPrincipal]
/// en `true` (solo lo pasan los dos Home reales) se renderiza la versión
/// "hero": logo, fondo verde institucional, esquinas redondeadas y avatar
/// premium — pensada específicamente para la pantalla de inicio.
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool mostrarFlecha;
  final List<Widget> extraActions;
  final bool esPantallaPrincipal;

  const HomeAppBar({
    super.key,
    this.mostrarFlecha = false,
    this.extraActions = const [],
    this.esPantallaPrincipal = false,
  });

  static const double _alturaCompacta = 64;
  static const double _alturaHero = 124;

  @override
  Size get preferredSize =>
      Size.fromHeight(esPantallaPrincipal ? _alturaHero : _alturaCompacta);

  @override
  Widget build(BuildContext context) {
    return esPantallaPrincipal
        ? _HeroHeader(extraActions: extraActions)
        : _CompactHeader(
            mostrarFlecha: mostrarFlecha,
            extraActions: extraActions,
          );
  }
}

// ── Avatar: resolución de URL + render, compartidos por ambas variantes ────

/// Selecciona solo `perfil` de `ProfileProvider` (no todo el provider), así
/// un cambio en otro campo del provider no reconstruye el header entero.
String _avatarUrlDe(PerfilEntity? perfil) {
  final tieneFotoPropia = perfil != null && perfil.ImgUrl.isNotEmpty;
  return tieneFotoPropia
      ? perfil.ImgUrl
      : getIt<AvatarService>().avatarPorDefecto(
          seed: perfil?.nombre ?? perfil?.id ?? 'explorachiapas',
        );
}

/// Imagen circular del avatar con placeholder/error compartidos — antes
/// duplicado idéntico en la variante compacta y en la hero.
class _AvatarImage extends StatelessWidget {
  final String url;
  final double size;

  const _AvatarImage({required this.url, required this.size});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, _) => _fallback(context),
      errorWidget: (_, _, _) => _fallback(context),
    );
  }

  Widget _fallback(BuildContext context) => Container(
    color: AppColors.primaryContainer(context),
    child: Icon(
      Icons.person,
      color: AppColors.primary(context),
      size: size * 0.45,
    ),
  );
}

/// Placa circular del logo (fondo blanco + sombra) — mismo patrón en
/// ambas variantes, solo cambia el tamaño.
class _LogoPlate extends StatelessWidget {
  final double size;

  const _LogoPlate({required this.size});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(size * 0.14),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        // ClipOval: el JPG es rectangular, la placa es circular — evita
        // que asome una esquina cuadrada.
        child: ClipOval(child: Image.asset(_logoAsset, fit: BoxFit.contain)),
      ),
    );
  }
}

// ── Variante compacta (sin cambios de diseño respecto al header original) ──

class _CompactHeader extends StatelessWidget {
  final bool mostrarFlecha;
  final List<Widget> extraActions;

  const _CompactHeader({
    required this.mostrarFlecha,
    required this.extraActions,
  });

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.sizeOf(context).width;
    final logoSize = (screenW * 0.1).clamp(36.0, 52.0);
    final fontSize = (screenW * 0.052).clamp(18.0, 22.0);
    final avatarRadius = (screenW * 0.06).clamp(20.0, 26.0);

    return AppBar(
      backgroundColor: AppColors.surface(context),
      elevation: 0,
      automaticallyImplyLeading: mostrarFlecha,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(
          height: 1,
          thickness: 1,
          color: AppColors.borderSubtle(context),
        ),
      ),
      titleSpacing: screenW * 0.04,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: logoSize,
            height: logoSize,
            child: Image.asset(_logoAsset, fit: BoxFit.contain),
          ),
          SizedBox(width: screenW * 0.022),
          Flexible(
            child: Text(
              'ExploraChiapas',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: const Color(0xFF2E7D32),
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
      actions: [
        ...extraActions,
        Padding(
          padding: EdgeInsets.only(right: screenW * 0.04),
          child: Selector<ProfileProvider, PerfilEntity?>(
            selector: (_, provider) => provider.perfil,
            builder: (context, perfil, _) => GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/perfil'),
              child: Container(
                width: avatarRadius * 2,
                height: avatarRadius * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary(context).withValues(alpha: 0.35),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: _AvatarImage(
                    url: _avatarUrlDe(perfil),
                    size: avatarRadius * 2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Variante "hero" — pantalla principal ────────────────────────────────────

class _HeroHeader extends StatefulWidget {
  final List<Widget> extraActions;

  const _HeroHeader({required this.extraActions});

  @override
  State<_HeroHeader> createState() => _HeroHeaderState();
}

class _HeroHeaderState extends State<_HeroHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entryCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  )..forward();
  late final Animation<double> _fade = CurvedAnimation(
    parent: _entryCtrl,
    curve: Curves.easeOut,
  );
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, -0.15),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));

  bool _avatarPresionado = false;

  @override
  void dispose() {
    _entryCtrl.dispose();
    super.dispose();
  }

  void _abrirPerfil() => Navigator.pushNamed(context, '/perfil');

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.sizeOf(context).width;
    final isDark = AppColors.isDark(context);

    // Logo y avatar reducidos frente al diseño anterior — el header debe
    // sentirse ligero, no protagonizar la pantalla.
    final logoSize = (screenW * 0.13).clamp(46.0, 58.0);
    final tituloSize = (screenW * 0.058).clamp(20.0, 24.0);
    final avatarRadius = (screenW * 0.062).clamp(22.0, 27.0);

    final verde = AppColors.primary(context);
    // Un solo tono (verde de marca, con una variación sutil del mismo
    // verde para dar profundidad) — nada de degradados multicolor ni
    // azul en el fondo, para mantener el header limpio y consistente
    // con el resto de la identidad visual. El azul institucional
    // (#1565C0) se reserva como acento de acción (botones "Trazar ruta")
    // en el resto de la app, no como color de fondo aquí.
    final verdeOscuro = Color.lerp(verde, Colors.black, isDark ? 0.32 : 0.12)!;

    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: verde.withValues(alpha: isDark ? 0.3 : 0.18),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [verdeOscuro, verde],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenW * 0.045,
                    vertical: screenW * 0.03,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _LogoPlate(size: logoSize),
                      SizedBox(width: screenW * 0.032),
                      Expanded(child: _HeroTitleBlock(tituloSize: tituloSize)),
                      SizedBox(width: screenW * 0.028),
                      ...widget.extraActions,
                      Selector<ProfileProvider, PerfilEntity?>(
                        selector: (_, provider) => provider.perfil,
                        builder: (context, perfil, _) => _AvatarHero(
                          avatarUrl: _avatarUrlDe(perfil),
                          radius: avatarRadius,
                          presionado: _avatarPresionado,
                          onPointerDown: () =>
                              setState(() => _avatarPresionado = true),
                          onPointerUp: () =>
                              setState(() => _avatarPresionado = false),
                          onTap: _abrirPerfil,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroTitleBlock extends StatelessWidget {
  final double tituloSize;

  const _HeroTitleBlock({required this.tituloSize});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'ExploraChiapas',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: tituloSize,
            letterSpacing: 0.1,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'Tu guía turística en Chiapas',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.88),
            fontWeight: FontWeight.w500,
            fontSize: tituloSize * 0.44,
            letterSpacing: 0.15,
          ),
        ),
      ],
    );
  }
}

class _AvatarHero extends StatelessWidget {
  final String avatarUrl;
  final double radius;
  final bool presionado;
  final VoidCallback onPointerDown;
  final VoidCallback onPointerUp;
  final VoidCallback onTap;

  const _AvatarHero({
    required this.avatarUrl,
    required this.radius,
    required this.presionado,
    required this.onPointerDown,
    required this.onPointerUp,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => onPointerDown(),
      onPointerUp: (_) => onPointerUp(),
      onPointerCancel: (_) => onPointerUp(),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          scale: presionado ? 0.92 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: Container(
            width: radius * 2,
            height: radius * 2,
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.9),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ClipOval(
              child: _AvatarImage(url: avatarUrl, size: radius * 2),
            ),
          ),
        ),
      ),
    );
  }
}
