import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class MapFilterBar extends StatefulWidget {
  final void Function(String? tipo) onFilterChanged;
  const MapFilterBar({super.key, required this.onFilterChanged});

  @override
  State<MapFilterBar> createState() => _MapFilterBarState();
}

class _MapFilterBarState extends State<MapFilterBar> {
  String? _selected;

  static const _filtros = [
    {'label': 'Todos', 'value': null, 'icon': Icons.map_outlined},
    {'label': 'Naturaleza', 'value': 'naturaleza', 'icon': Icons.eco_outlined},
    {
      'label': 'Cultura',
      'value': 'cultura',
      'icon': Icons.account_balance_outlined,
    },
    {
      'label': 'Gastronomía',
      'value': 'gastronomia',
      'icon': Icons.restaurant_outlined,
    },
    {'label': 'Aventura', 'value': 'aventura', 'icon': Icons.kayaking_outlined},
    {'label': 'Descanso', 'value': 'descanso', 'icon': Icons.spa_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filtros.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final f = _filtros[i];
          final isActive = _selected == f['value'];
          return GestureDetector(
            onTap: () {
              setState(() => _selected = f['value'] as String?);
              widget.onFilterChanged(f['value'] as String?);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary(context)
                    : AppColors.surface(context),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive
                      ? AppColors.primary(context)
                      : AppColors.borderSubtle(context),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    f['icon'] as IconData,
                    size: 16,
                    color: isActive
                        ? (AppColors.isDark(context) ? Colors.black : Colors.white)
                        : AppColors.primary(context),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    f['label'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? (AppColors.isDark(context) ? Colors.black : Colors.white)
                          : AppColors.textPrimary(context),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
