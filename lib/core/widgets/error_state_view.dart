import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Estado de error reutilizable (Favoritos, Reseñas...) — backend caído,
/// sin conexión, respuesta inesperada, etc. — siempre con una salida
/// clara para reintentar, nunca deja al usuario atrapado sin acción.
class ErrorStateView extends StatelessWidget {
  final String mensaje;
  final String retryLabel;
  final VoidCallback onRetry;

  const ErrorStateView({
    super.key,
    required this.mensaje,
    required this.onRetry,
    this.retryLabel = 'Reintentar',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: AppColors.errorContainer(context),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                size: 36,
                color: AppColors.error(context),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary(context),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(retryLabel),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary(context),
                foregroundColor: AppColors.onPrimary(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
