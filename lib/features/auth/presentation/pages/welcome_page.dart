import 'package:flutter/material.dart';
import '../widgets/auth_button.dart';

/// Pantalla puramente de presentación (Registro/Inicio de sesión).
///
/// Ya NO valida sesión aquí — esa decisión (Home vs. Welcome) la toma
/// `SplashPage`, una sola vez, antes de que esta ruta siquiera exista en
/// el stack. Antes esta pantalla lanzaba su propia verificación asíncrona
/// contra el backend en `initState`, y si el usuario tocaba "INICIAR
/// SESIÓN" antes de que esa verificación terminara, la respuesta tardía
/// terminaba reemplazando la pantalla de Login con Home a mitad de
/// camino (ver `SplashPage` para el detalle de la condición de carrera).
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

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
