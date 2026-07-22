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
          // Expanded: el título nunca empuja "Ver todos" fuera de la
          // pantalla en títulos largos o teléfonos angostos — se recorta
          // con ellipsis en vez de desbordar (evita el "tarjetazo
          // amarillo" de RenderFlex overflow).
          Expanded(
            child: Row(
              children: [
                Icon(icon, size: 20, color: AppColors.primary(context)),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    titulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (mostrarVerTodos) ...[
            const SizedBox(width: 8),
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
        ],
      ),
    );
  }
}
