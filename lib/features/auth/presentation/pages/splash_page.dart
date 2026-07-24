import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/storage/secure_session_storage.dart';
import '../../../../core/utils/app_constants.dart';
import '../providers/auth_provider.dart';

/// Único punto donde se decide Home-vs-Welcome al arrancar la app.
///
/// Antes esta validación vivía dentro de `WelcomePage` (disparada en un
/// `postFrameCallback` de su `initState`), lo cual abría una condición de
/// carrera real: si el usuario tocaba "INICIAR SESIÓN" en Welcome antes de
/// que la verificación (que espera una llamada de red a
/// `loadUserInterests`) terminara, esa verificación tardía igual llamaba a
/// `Navigator.pushReplacementNamed(context, ...)`. Como
/// `pushReplacementNamed` reemplaza la ruta que esté ARRIBA del stack en
/// ese momento —no necesariamente la que originó la llamada—, terminaba
/// reemplazando la pantalla de Login (a la que el usuario ya había
/// navegado) con Home, saltándose por completo el formulario de inicio de
/// sesión.
///
/// `SplashPage` es su propia ruta, sin botones ni forma de navegar fuera
/// de ella mientras se valida: la decisión Home-vs-Welcome ocurre una sola
/// vez, antes de que exista ninguna otra ruta en el stack con la que
/// pueda chocar.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _decidirDestino());
  }

  Future<void> _decidirDestino() async {
    final token = await getIt<SecureSessionStorage>().getToken();
    if (!mounted) return;

    if (token == null || token.isEmpty) {
      Navigator.pushReplacementNamed(context, '/welcome');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final interests = await authProvider.loadUserInterests();
    if (!mounted) return;

    if (interests == null) {
      // Token presente pero no se pudo confirmar contra el backend (sin
      // conexión, servidor caído, etc.): se cae al caché local en vez de
      // dejar al usuario varado en el splash.
      final prefs = await SharedPreferences.getInstance();
      final onboardingCompleto =
          prefs.getBool(AppConstants.onboardingKey) ?? false;
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        onboardingCompleto ? '/home' : '/intereses',
      );
      return;
    }

    Navigator.pushReplacementNamed(
      context,
      interests.onboardingCompleted ? '/home' : '/intereses',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B5E20),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 3),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/ExploraChiapas Logo.png',
                    width: 88,
                    height: 88,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'ExploraChiapas',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Descubre la magia de Chiapas',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Spacer(flex: 3),
            const Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
