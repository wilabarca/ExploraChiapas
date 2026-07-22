import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Estado vacío reutilizable (Favoritos, Reseñas...) con animación de
/// entrada suave. El mensaje lo decide cada pantalla según el contexto
/// (vacío general vs. vacío por categoría filtrada, por ejemplo).
class EmptyStateView extends StatelessWidget {
  final String mensaje;
  final IconData icon;
  final Widget? accion;

  const EmptyStateView({
    super.key,
    required this.mensaje,
    this.icon = Icons.inbox_outlined,
    this.accion,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.scale(scale: 0.9 + (0.1 * value), child: child),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer(context),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 38, color: AppColors.textHint(context)),
              ),
              const SizedBox(height: 18),
              Text(
                mensaje,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary(context),
                ),
              ),
              if (accion != null) ...[const SizedBox(height: 16), accion!],
            ],
          ),
        ),
      ),
    );
  }
}
