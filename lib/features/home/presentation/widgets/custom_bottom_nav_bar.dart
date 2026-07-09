import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<_NavItemData> _items = [
    _NavItemData(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Inicio',
    ),
    _NavItemData(
      icon: Icons.map_outlined,
      activeIcon: Icons.map,
      label: 'Mapa',
    ),
    _NavItemData(
      icon: Icons.favorite_outline,
      activeIcon: Icons.favorite,
      label: 'Favoritos',
    ),
    _NavItemData(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Perfil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = MediaQuery.of(context).size.width;

          // --- Detectores de restricciones / breakpoints ---
          final isCompact = screenWidth < 360;
          final isTablet = screenWidth >= 600;

          final horizontalMargin = isTablet ? screenWidth * 0.15 : 16.0;
          final barHeight = isCompact ? 60.0 : (isTablet ? 76.0 : 68.0);
          final iconSize = isCompact ? 20.0 : (isTablet ? 26.0 : 22.0);
          final fontSize = isCompact ? 12.0 : (isTablet ? 15.0 : 13.0);
          final horizontalPadding = isCompact ? 10.0 : 14.0;

          return Container(
            margin: EdgeInsets.symmetric(
              horizontal: horizontalMargin,
              vertical: 10,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 8,
            ),
            // ConstrainedBox implícito: fija un rango seguro de alto.
            constraints: BoxConstraints(maxHeight: barHeight, minHeight: 52),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(barHeight),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_items.length, (index) {
                final selected = index == currentIndex;
                final item = _items[index];

                // Distribución proporcional: el activo "pesa" más (Flexible/flex).
                return Flexible(
                  flex: selected ? 3 : 1,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onTap(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      padding: EdgeInsets.symmetric(
                        horizontal: selected ? 14 : 8,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF2E7D32)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            selected ? item.activeIcon : item.icon,
                            size: iconSize,
                            color: selected
                                ? Colors.white
                                : const Color(0xFF999999),
                          ),
                          if (selected) ...[
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                item.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: fontSize,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        },
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
