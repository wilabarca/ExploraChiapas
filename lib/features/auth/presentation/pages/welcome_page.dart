import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/storage/secure_session_storage.dart';
import '../../../biometric_auth/domain/entities/biometric_availability.dart';
import '../../../biometric_auth/presentation/providers/biometric_auth_provider.dart';
import '../widgets/auth_button.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();
    // Se difiere hasta después del primer frame: BiometricAuthProvider
    // hace notifyListeners() de inmediato (antes de cualquier await), y
    // llamarlo en initState sin esperar al post-frame dispara
    // "setState()/markNeedsBuild() called during build" porque el árbol
    // de widgets todavía se está construyendo.
    WidgetsBinding.instance.addPostFrameCallback((_) => _verificarSesion());
  }

  Future<void> _verificarSesion() async {
    if (!mounted) return;

    // La huella digital es el único método de acceso: se comprueba el
    // dispositivo ANTES que cualquier otra cosa, sin importar si ya hay
    // una sesión guardada o no.
    final biometricProvider = context.read<BiometricAuthProvider>();
    final disponibilidad = await biometricProvider.verificarDisponibilidad();
    if (!mounted) return;

    if (!disponibilidad.esUtilizable) {
      Navigator.pushReplacementNamed(context, '/biometria-no-disponible');
      return;
    }

    final token = await getIt<SecureSessionStorage>().getToken();
    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      // Ya existe una sesión: en vez de entrar directo, se exige validar
      // la huella para restaurarla. FingerprintGatePage decide a dónde ir
      // (Home o Intereses) una vez verificada.
      Navigator.pushReplacementNamed(context, '/huella');
    }
    // Sin sesión guardada: se queda en esta pantalla mostrando los botones
    // de Registro/Inicio de sesión, tal como antes (primer ingreso).
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF012D18), Color(0xFF006633)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 35),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(height: size.height * 0.05),

                SizedBox(
                  width: size.width * 0.52,
                  height: size.height * 0.30,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/images/inicio.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                SizedBox(height: size.height * 0.04),

                Text(
                  'Explora la Magia\nde Chiapas',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size.height * 0.045,
                    fontWeight: FontWeight.bold,
                    height: 1.15,
                  ),
                ),

                SizedBox(height: size.height * 0.018),

                Text(
                  'Tu aventura sostenible comienza aquí.\n'
                  'Descubre rutas únicas y apoya a las\n'
                  'comunidades locales.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: size.height * 0.017,
                    height: 1.6,
                  ),
                ),

                const Spacer(),

                AuthButton(
                  text: 'COMENZAR REGISTRO',
                  isPrimary: true,
                  onPressed: () => Navigator.pushNamed(context, '/registro'),
                ),

                SizedBox(height: size.height * 0.016),

                AuthButton(
                  text: 'INICIAR SESIÓN',
                  isPrimary: false,
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                ),

                SizedBox(height: size.height * 0.04),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
