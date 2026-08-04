import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/press_scale.dart';
import '../widgets/auth_button.dart';
import 'login_page.dart';
import 'register_page.dart';

/// Pantalla puramente de presentación (Registro/Inicio de sesión).
///
/// Ya NO valida sesión aquí — esa decisión (Home vs. Welcome) la toma
/// `SplashPage`, una sola vez, antes de que esta ruta siquiera exista en
/// el stack. Antes esta pantalla lanzaba su propia verificación asíncrona
/// contra el backend en `initState`, y si el usuario tocaba "INICIAR
/// SESIÓN" antes de que esa verificación terminara, la respuesta tardía
/// terminaba reemplazando la pantalla de Login con Home a mitad de
/// camino (ver `SplashPage` para el detalle de la condición de carrera).
class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  // Un solo AnimationController maneja toda la entrada escalonada
  // (imagen → título → subtítulo → botones → insignia) vía `Interval`,
  // en vez de un controller por elemento — más barato y sin riesgo de
  // fugas por olvidar liberar alguno.
  late final AnimationController _controller;

  late final Animation<double> _imagenFade;
  late final Animation<double> _imagenScale;
  late final Animation<double> _tituloFade;
  late final Animation<Offset> _tituloSlide;
  late final Animation<double> _subtituloFade;
  late final Animation<Offset> _subtituloSlide;
  late final Animation<double> _botonesFade;
  late final Animation<Offset> _botonesSlide;
  late final Animation<double> _badgeFade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _imagenFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    );
    _imagenScale = Tween(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
      ),
    );

    _tituloFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.25, 0.75, curve: Curves.easeOut),
    );
    _tituloSlide = Tween(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.25, 0.75, curve: Curves.easeOutCubic),
          ),
        );

    _subtituloFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 0.85, curve: Curves.easeOut),
    );
    _subtituloSlide = Tween(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.35, 0.85, curve: Curves.easeOutCubic),
          ),
        );

    _botonesFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    );
    _botonesSlide = Tween(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _badgeFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Transición propia (fade + slide sutil) en vez de la ruta con nombre
  // ('/login', '/registro' vía onGenerateRoute), que usa la transición
  // por defecto de la plataforma. Ni LoginPage ni RegisterPage dependen
  // del nombre de ruta (no usan RouteAware ni leen `settings`), así que
  // este atajo no rompe nada.
  void _irA(Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 380),
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          final curva = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curva,
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(curva),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              SizedBox(height: size.height * 0.02),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ExploraChiapas',
                    style: TextStyle(
                      color: AppColors.primary(context),
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const _BotonIdioma(),
                ],
              ),

              SizedBox(height: size.height * 0.025),

              FadeTransition(
                opacity: _imagenFade,
                child: ScaleTransition(
                  scale: _imagenScale,
                  // RepaintBoundary aísla el bitmap (estático una vez
                  // decodificado) del resto del árbol, que sí sigue
                  // animándose durante la entrada.
                  child: RepaintBoundary(
                    child: SizedBox(
                      width: double.infinity,
                      height: size.height * 0.42,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Image.asset(
                          'assets/images/maya.png',
                          fit: BoxFit.cover,
                          // Evita decodificar a una resolución mayor que
                          // la que realmente se va a pintar en pantalla.
                          cacheWidth: (size.width * 2).round(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: size.height * 0.035),

              FadeTransition(
                opacity: _tituloFade,
                child: SlideTransition(
                  position: _tituloSlide,
                  child: Text(
                    'Explora la magia\nde Chiapas',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                ),
              ),

              SizedBox(height: size.height * 0.016),

              FadeTransition(
                opacity: _subtituloFade,
                child: SlideTransition(
                  position: _subtituloSlide,
                  child: Text(
                    'Tu aventura sostenible comienza aquí.\n'
                    'Descubre rutas únicas y apoya a las\n'
                    'comunidades locales.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 14.5,
                      height: 1.55,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              FadeTransition(
                opacity: _botonesFade,
                child: SlideTransition(
                  position: _botonesSlide,
                  child: Column(
                    children: [
                      AuthButton(
                        text: 'Comenzar registro',
                        isPrimary: true,
                        onPressed: () => _irA(const RegisterPage()),
                      ),
                      const SizedBox(height: 14),
                      AuthButton(
                        text: 'Iniciar sesión',
                        isPrimary: false,
                        onPressed: () => _irA(const LoginPage()),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: size.height * 0.022),

              FadeTransition(
                opacity: _badgeFade,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer(context),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.eco,
                        size: 14,
                        color: AppColors.primary(context),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Turismo Consciente & Sustentable',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onPrimaryContainer(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: size.height * 0.03),
            ],
          ),
        ),
      ),
    );
  }
}

/// Botón circular de idioma (es/en) — mismo lugar que el ícono de globo
/// de la referencia visual, pero funcional: alterna el idioma real de la
/// app vía `LocaleProvider` (ya usado en el resto de la app, no es un
/// botón decorativo sin acción). Es un `Consumer` acotado a sí mismo para
/// que un cambio de idioma no reconstruya el resto de la pantalla.
class _BotonIdioma extends StatelessWidget {
  const _BotonIdioma();

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, locale, _) {
        return Tooltip(
          message: locale.langCode == 'es'
              ? 'Cambiar a English'
              : 'Cambiar a Español',
          child: PressScale(
            onTap: () =>
                locale.setLocale(Locale(locale.langCode == 'es' ? 'en' : 'es')),
            scaleAbajo: 0.9,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.language,
                size: 19,
                color: AppColors.primary(context),
              ),
            ),
          ),
        );
      },
    );
  }
}
