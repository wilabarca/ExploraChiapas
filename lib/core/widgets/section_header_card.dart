import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Encabezado reutilizable para vistas de listado (Favoritos, Reseñas...):
/// ícono, título, subtítulo y contador opcional, con esquinas inferiores
/// redondeadas y sombra suave para separarse del fondo sin corte abrupto.
class SectionHeaderCard extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String subtitulo;
  final int? total;

  const SectionHeaderCard({
    super.key,
    required this.icon,
    required this.titulo,
    required this.subtitulo,
    this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: AppColors.isDark(context) ? 0.24 : 0.06,
            ),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer(context),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.primary(context), size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        titulo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary(context),
                          height: 1.15,
                        ),
                      ),
                    ),
                    if (total != null && total! > 0) ...[
                      const SizedBox(width: 8),
                      _ContadorBadge(total: total!),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitulo,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContadorBadge extends StatelessWidget {
  final int total;

  const _ContadorBadge({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer(context),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$total',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.primary(context),
        ),
      ),
    );
  }
}
