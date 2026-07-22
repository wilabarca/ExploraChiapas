import 'package:flutter/material.dart';
import 'core/di/injector.dart';
import 'core/services/notifications/onesignal_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Muestra el splash inmediatamente — sin DI, cero delay perceptible
  runApp(const _AppSplash());

  // Inicializa en paralelo (más rápido que secuencial)
  await Future.wait([configureDependencies(), OneSignalService.initialize()]);

  runApp(const ExploraChiapasApp());
}

class _AppSplash extends StatelessWidget {
  const _AppSplash();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
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
      ),
    );
  }
}
