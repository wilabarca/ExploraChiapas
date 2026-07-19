import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SectionHeader extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final bool mostrarVerTodos;
  final VoidCallback? onVerTodos;

  const SectionHeader({
    super.key,
    required this.icon,
    required this.titulo,
    this.mostrarVerTodos = false,
    this.onVerTodos,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary(context)),
              const SizedBox(width: 6),
              Text(
                titulo,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary(context),
                ),
              ),
            ],
          ),
          if (mostrarVerTodos)
            GestureDetector(
              onTap: onVerTodos,
              child: Text(
                'Ver todos',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primary(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
