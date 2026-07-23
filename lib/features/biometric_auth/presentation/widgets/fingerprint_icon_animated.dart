import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/biometric_auth_provider.dart';

/// Icono de huella con un halo pulsante mientras se espera/valida al
/// usuario, y una transición suave (fade + scale) al cambiar de ícono
/// cuando el estado pasa a éxito o error.
class FingerprintIconAnimated extends StatefulWidget {
  final BiometricGateStatus status;

  const FingerprintIconAnimated({super.key, required this.status});

  @override
  State<FingerprintIconAnimated> createState() =>
      _FingerprintIconAnimatedState();
}

class _FingerprintIconAnimatedState extends State<FingerprintIconAnimated>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  static const _estadosActivos = {
    BiometricGateStatus.idle,
    BiometricGateStatus.verificandoDisponibilidad,
    BiometricGateStatus.autenticando,
  };

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  bool get _pulsando => _estadosActivos.contains(widget.status);

  @override
  Widget build(BuildContext context) {
    final color = _colorPorEstado(context, widget.status);

    return SizedBox(
      width: 176,
      height: 176,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              if (!_pulsando) return const SizedBox.shrink();
              final t = _pulseController.value;
              return Opacity(
                opacity: (1 - t) * 0.35,
                child: Transform.scale(scale: 1 + t * 0.4, child: child),
              );
            },
            child: Container(
              width: 136,
              height: 136,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
          ),
          Container(
            width: 136,
            height: 136,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.12),
              border: Border.all(color: color, width: 2),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: Icon(
                _iconoPorEstado(widget.status),
                key: ValueKey(widget.status),
                size: 60,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconoPorEstado(BiometricGateStatus status) {
    return switch (status) {
      BiometricGateStatus.exito => Icons.check_circle,
      BiometricGateStatus.error => Icons.fingerprint,
      _ => Icons.fingerprint,
    };
  }

  Color _colorPorEstado(BuildContext context, BiometricGateStatus status) {
    return switch (status) {
      BiometricGateStatus.exito => AppColors.primary(context),
      BiometricGateStatus.error => AppColors.error(context),
      _ => AppColors.primary(context),
    };
  }
}
