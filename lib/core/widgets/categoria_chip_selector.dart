import 'package:flutter/material.dart';

import 'filtro_chip_option.dart';
import '../theme/app_colors.dart';

/// Selector de categorías estilo chips Material 3, reutilizado en
/// Favoritos, Reseñas y cualquier otra vista con filtros por categoría.
///
/// Desplazable horizontalmente para que nunca desborde sin importar
/// cuántas categorías traiga el backend. Cada chip anima su color,
/// tamaño y elevación al seleccionarse.
class CategoriaChipSelector extends StatelessWidget {
  final List<FiltroChipOption> opciones;
  final String seleccionId;
  final ValueChanged<String> onChanged;

  const CategoriaChipSelector({
    super.key,
    required this.opciones,
    required this.seleccionId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: opciones.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final opcion = opciones[index];
          final activo = opcion.id == seleccionId;
          return _Chip(
            opcion: opcion,
            activo: activo,
            onTap: () => onChanged(opcion.id),
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final FiltroChipOption opcion;
  final bool activo;
  final VoidCallback onTap;

  const _Chip({
    required this.opcion,
    required this.activo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = activo
        ? AppColors.onPrimary(context)
        : AppColors.textSecondary(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: activo
                ? AppColors.primary(context)
                : AppColors.surface(context),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: activo
                  ? AppColors.primary(context)
                  : AppColors.border(context),
              width: 1.2,
            ),
            boxShadow: activo
                ? [
                    BoxShadow(
                      color: AppColors.primary(context).withValues(alpha: 0.28),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: Icon(
                  opcion.icon,
                  key: ValueKey(activo),
                  size: 16,
                  color: fg,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                opcion.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: activo ? FontWeight.w700 : FontWeight.w600,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
