import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/biometric_availability.dart';
import '../providers/biometric_auth_provider.dart';

/// Pantalla amigable para dispositivos que no pueden usar huella digital
/// (sin sensor, sensor deshabilitado, o sin huellas registradas). Como la
/// huella es el único método de acceso, aquí se explica la situación y se
/// ofrece la acción para resolverla, sin cerrar la app ni producir errores.
class BiometricUnavailablePage extends StatefulWidget {
  const BiometricUnavailablePage({super.key});

  @override
  State<BiometricUnavailablePage> createState() =>
      _BiometricUnavailablePageState();
}

class _BiometricUnavailablePageState extends State<BiometricUnavailablePage> {
  bool _revisando = false;

  Future<void> _reintentar() async {
    if (_revisando) return;
    setState(() => _revisando = true);

    final provider = context.read<BiometricAuthProvider>();
    final disponibilidad = await provider.verificarDisponibilidad();
    if (!mounted) return;

    setState(() => _revisando = false);

    if (disponibilidad.esUtilizable) {
      // Vuelve a la raíz: WelcomePage decide de nuevo (con huella ya
      // disponible) si corresponde restaurar sesión o mostrar login.
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Consumer<BiometricAuthProvider>(
              builder: (context, provider, _) {
                final motivo = provider.disponibilidad;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.errorContainer(context),
                      ),
                      child: Icon(
                        Icons.fingerprint_outlined,
                        size: 56,
                        color: AppColors.error(context),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      _titulo(motivo),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _descripcion(motivo),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _revisando ? null : _reintentar,
                        icon: _revisando
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.onPrimary(context),
                                ),
                              )
                            : const Icon(Icons.refresh),
                        label: Text(
                          _revisando
                              ? 'Verificando…'
                              : 'Ya configuré mi huella',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary(context),
                          foregroundColor: AppColors.onPrimary(context),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  String _titulo(BiometricAvailability? motivo) {
    switch (motivo) {
      case BiometricAvailability.sinHuellasRegistradas:
        return 'Registra una huella para continuar';
      case BiometricAvailability.sinHardware:
        return 'Tu dispositivo no tiene sensor de huella';
      case BiometricAvailability.noSoportado:
      default:
        return 'La huella digital no está disponible';
    }
  }

  String _descripcion(BiometricAvailability? motivo) {
    switch (motivo) {
      case BiometricAvailability.sinHuellasRegistradas:
        return 'ExploraChiapas usa exclusivamente tu huella digital para '
            'proteger tu cuenta. Ve a Ajustes > Seguridad > Huella digital '
            'en tu dispositivo, registra al menos una huella y vuelve aquí.';
      case BiometricAvailability.sinHardware:
        return 'Este dispositivo no cuenta con sensor de huella digital, '
            'así que no es posible iniciar sesión en ExploraChiapas desde él.';
      case BiometricAvailability.noSoportado:
      default:
        return 'No fue posible detectar soporte de huella digital en este '
            'dispositivo. Verifica que tenga un bloqueo de pantalla '
            'configurado y una huella registrada, y vuelve a intentarlo.';
    }
  }
}
