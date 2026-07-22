import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class EventoFiltroChip extends StatelessWidget {
  final String label;
  final bool activo;
  final VoidCallback onTap;

  const EventoFiltroChip({
    super.key,
    required this.label,
    required this.activo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: activo
              ? AppColors.primary(context)
              : AppColors.surface(context),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: activo
                ? AppColors.primary(context)
                : AppColors.border(context),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: activo
                ? AppColors.onPrimary(context)
                : AppColors.textSecondary(context),
          ),
        ),
      ),
    );
  }
}
