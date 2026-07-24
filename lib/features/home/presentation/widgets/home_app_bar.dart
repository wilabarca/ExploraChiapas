import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/services/avatar/avatar_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

/// Header compartido de la app. Por defecto es la barra compacta de
/// siempre (usada en ~10 pantallas internas: perfil, favoritos,
/// promociones, reseñas, etc. — no se tocó su diseño para no arrastrar
/// cambios a pantallas que no pidieron rediseño). Con [esPantallaPrincipal]
/// en `true` (solo lo pasan los dos Home reales) se renderiza la versión
/// "hero": logo grande, fondo verde institucional, esquinas redondeadas y
/// avatar premium — pensada específicamente para la pantalla de inicio.
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
  static const double _alturaHero = 132;

  @override
  Size get preferredSize =>
      Size.fromHeight(esPantallaPrincipal ? _alturaHero : _alturaCompacta);

  @override
  Widget build(BuildContext context) {
    if (esPantallaPrincipal) {
      return _HeroHeader(extraActions: extraActions);
    }
    return _CompactHeader(
      mostrarFlecha: mostrarFlecha,
      extraActions: extraActions,
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
    final screenW = MediaQuery.of(context).size.width;
    final logoSize = (screenW * 0.1).clamp(36.0, 52.0);
    final fontSize = (screenW * 0.052).clamp(18.0, 22.0);
    final avatarRadius = (screenW * 0.06).clamp(20.0, 26.0);

    final perfil = context.watch<ProfileProvider>().perfil;
    final tieneFotoPropia = perfil != null && perfil.ImgUrl.isNotEmpty;
    final avatarUrl = tieneFotoPropia
        ? perfil.ImgUrl
        : getIt<AvatarService>().avatarPorDefecto(
            seed: perfil?.nombre ?? perfil?.id ?? 'explorachiapas',
          );

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
      title: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: logoSize,
                height: logoSize,
                child: Image.asset(
                  'assets/images/ExploraChiapas Logo.png',
                  fit: BoxFit.contain,
                ),
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
          );
        },
      ),
      actions: [
        ...extraActions,
        Padding(
          padding: EdgeInsets.only(right: screenW * 0.04),
          child: GestureDetector(
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
                child: CachedNetworkImage(
                  imageUrl: avatarUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: AppColors.primaryContainer(context),
                    child: Icon(
                      Icons.person,
                      color: AppColors.primary(context),
                      size: avatarRadius * 0.9,
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: AppColors.primaryContainer(context),
                    child: Icon(
                      Icons.person,
                      color: AppColors.primary(context),
                      size: avatarRadius * 0.9,
                    ),
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

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final isDark = AppColors.isDark(context);

    final logoSize = (screenW * 0.16).clamp(58.0, 76.0);
    final tituloSize = (screenW * 0.062).clamp(21.0, 26.0);
    final avatarRadius = (screenW * 0.072).clamp(26.0, 32.0);

    final perfil = context.watch<ProfileProvider>().perfil;
    final tieneFotoPropia = perfil != null && perfil.ImgUrl.isNotEmpty;
    final avatarUrl = tieneFotoPropia
        ? perfil.ImgUrl
        : getIt<AvatarService>().avatarPorDefecto(
            seed: perfil?.nombre ?? perfil?.id ?? 'explorachiapas',
          );

    final verde = AppColors.primary(context);
    // Un solo tono (verde de marca, con una variación sutil del mismo
    // verde para dar profundidad) — nada de degradados multicolor ni
    // azul en el fondo, para mantener el header limpio y consistente
    // con el resto de la identidad visual.
    final verdeOscuro = Color.lerp(verde, Colors.black, isDark ? 0.32 : 0.12)!;

    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: verde.withValues(alpha: isDark ? 0.35 : 0.22),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        child: Container(
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
                  padding: EdgeInsets.fromLTRB(
                    screenW * 0.05,
                    screenW * 0.03,
                    screenW * 0.04,
                    screenW * 0.045,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Logo protagonista sobre placa blanca para contraste.
                      Container(
                        width: logoSize,
                        height: logoSize,
                        padding: EdgeInsets.all(logoSize * 0.14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/ExploraChiapas Logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(width: screenW * 0.035),
                      Expanded(
                        child: Column(
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
                        ),
                      ),
                      SizedBox(width: screenW * 0.03),
                      ...widget.extraActions,
                      _AvatarHero(
                        avatarUrl: avatarUrl,
                        radius: avatarRadius,
                        presionado: _avatarPresionado,
                        onPointerDown: () =>
                            setState(() => _avatarPresionado = true),
                        onPointerUp: () =>
                            setState(() => _avatarPresionado = false),
                        onTap: () => Navigator.pushNamed(context, '/perfil'),
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: avatarUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: AppColors.primaryContainer(context),
                  child: Icon(
                    Icons.person,
                    color: AppColors.primary(context),
                    size: radius * 0.9,
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.primaryContainer(context),
                  child: Icon(
                    Icons.person,
                    color: AppColors.primary(context),
                    size: radius * 0.9,
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
