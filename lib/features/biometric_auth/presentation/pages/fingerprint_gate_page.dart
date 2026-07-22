import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/biometric_availability.dart';
import '../providers/biometric_auth_provider.dart';
import '../widgets/fingerprint_icon_animated.dart';

/// Puerta de acceso biométrica: se muestra cuando ya existe una sesión
/// guardada y el dispositivo soporta huella digital. Ninguna pantalla
/// protegida es alcanzable sin pasar por aquí primero.
class FingerprintGatePage extends StatefulWidget {
  const FingerprintGatePage({super.key});

  @override
  State<FingerprintGatePage> createState() => _FingerprintGatePageState();
}

class _FingerprintGatePageState extends State<FingerprintGatePage> {
  bool _cerrandoSesion = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _iniciarFlujo());
  }

  Future<void> _iniciarFlujo() async {
    if (!mounted) return;
    final provider = context.read<BiometricAuthProvider>();

    final disponibilidad = await provider.verificarDisponibilidad();
    if (!mounted) return;

    if (!disponibilidad.esUtilizable) {
      Navigator.pushReplacementNamed(context, '/biometria-no-disponible');
      return;
    }

    await _autenticar();
  }

  Future<void> _autenticar() async {
    if (!mounted) return;
    final provider = context.read<BiometricAuthProvider>();
    final ok = await provider.autenticar();
    if (!mounted || !ok) return;

    // Breve pausa para que el usuario perciba la confirmación de éxito
    // antes de navegar, en vez de un salto abrupto.
    await Future.delayed(const Duration(milliseconds: 550));
    if (!mounted) return;
    await _irAlDestinoDeSesion();
  }

  Future<void> _irAlDestinoDeSesion() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingCompleto =
        prefs.getBool(AppConstants.onboardingKey) ?? false;
    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context,
      onboardingCompleto ? '/home' : '/intereses',
    );
  }

  Future<void> _cerrarSesion() async {
    if (_cerrandoSesion) return;
    setState(() => _cerrandoSesion = true);
    try {
      await context.read<AuthProvider>().logout();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } finally {
      if (mounted) setState(() => _cerrandoSesion = false);
    }
  }

  // Razones ante las que la huella de este dispositivo ya no es una vía de
  // acceso viable: se ofrece cerrar sesión para poder entrar con
  // correo/contraseña en vez de dejar al usuario sin salida.
  bool _esIrrecuperable(BiometricFailureReason reason) {
    return reason == BiometricFailureReason.notEnrolled ||
        reason == BiometricFailureReason.notAvailable ||
        reason == BiometricFailureReason.passcodeNotSet ||
        reason == BiometricFailureReason.permanentlyLockedOut;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: Center(
          child: Consumer<BiometricAuthProvider>(
            builder: (context, provider, _) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.eco_outlined,
                      size: 34,
                      color: AppColors.primary(context),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ExploraChiapas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary(context),
                      ),
                    ),
                    const SizedBox(height: 48),
                    FingerprintIconAnimated(status: provider.status),
                    const SizedBox(height: 32),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _Mensaje(
                        key: ValueKey(
                          '${provider.status}-${provider.errorReason}',
                        ),
                        provider: provider,
                      ),
                    ),
                    const SizedBox(height: 28),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _Acciones(
                        key: ValueKey('acciones-${provider.status}'),
                        provider: provider,
                        cerrandoSesion: _cerrandoSesion,
                        onReintentar: _autenticar,
                        onCerrarSesion:
                            provider.errorReason != null &&
                                _esIrrecuperable(provider.errorReason!)
                            ? _cerrarSesion
                            : null,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Mensaje extends StatelessWidget {
  final BiometricAuthProvider provider;
  const _Mensaje({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final String titulo;
    final String subtitulo;

    switch (provider.status) {
      case BiometricGateStatus.verificandoDisponibilidad:
        titulo = 'Verificando tu dispositivo…';
        subtitulo = 'Un momento, por favor.';
        break;
      case BiometricGateStatus.autenticando:
        titulo = 'Coloca tu dedo en el sensor';
        subtitulo = 'Estamos verificando tu identidad.';
        break;
      case BiometricGateStatus.exito:
        titulo = '¡Huella verificada!';
        subtitulo = 'Ingresando a tu cuenta…';
        break;
      case BiometricGateStatus.error:
        titulo = 'No se pudo verificar tu huella';
        subtitulo = provider.errorMessage ?? 'Inténtalo de nuevo.';
        break;
      case BiometricGateStatus.idle:
        titulo = 'Coloca tu dedo en el sensor';
        subtitulo = 'Usaremos tu huella para ingresar de forma segura.';
        break;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          titulo,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitulo,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 1.4,
            color: AppColors.textSecondary(context),
          ),
        ),
      ],
    );
  }
}

class _Acciones extends StatelessWidget {
  final BiometricAuthProvider provider;
  final bool cerrandoSesion;
  final VoidCallback onReintentar;
  final VoidCallback? onCerrarSesion;

  const _Acciones({
    super.key,
    required this.provider,
    required this.cerrandoSesion,
    required this.onReintentar,
    required this.onCerrarSesion,
  });

  @override
  Widget build(BuildContext context) {
    if (provider.status == BiometricGateStatus.autenticando ||
        provider.status == BiometricGateStatus.verificandoDisponibilidad) {
      return SizedBox(
        height: 44,
        width: 44,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          color: AppColors.primary(context),
        ),
      );
    }

    if (provider.status != BiometricGateStatus.error) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onReintentar,
            icon: const Icon(Icons.fingerprint),
            label: const Text('Reintentar'),
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
        if (onCerrarSesion != null) ...[
          const SizedBox(height: 12),
          TextButton(
            onPressed: cerrandoSesion ? null : onCerrarSesion,
            child: Text(
              cerrandoSesion ? 'Cerrando sesión…' : 'Cerrar sesión',
              style: TextStyle(color: AppColors.textSecondary(context)),
            ),
          ),
        ],
      ],
    );
  }
}
