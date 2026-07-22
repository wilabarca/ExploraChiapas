import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

enum BottomNavTab { explorar, mapa, favoritos, resenas, perfil }

class AppBottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final BottomNavTab tab;

  const AppBottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.tab,
  });
}

class AppBottomNav extends StatelessWidget {
  final BottomNavTab currentTab;
  final ValueChanged<BottomNavTab> onTap;
  final List<AppBottomNavItem> navItems;

  static const List<AppBottomNavItem> items = [
    AppBottomNavItem(
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore,
      label: 'Explorar',
      tab: BottomNavTab.explorar,
    ),
    AppBottomNavItem(
      icon: Icons.map_outlined,
      activeIcon: Icons.map,
      label: 'Mapa',
      tab: BottomNavTab.mapa,
    ),
    AppBottomNavItem(
      icon: Icons.favorite_outline,
      activeIcon: Icons.favorite,
      label: 'Favoritos',
      tab: BottomNavTab.favoritos,
    ),
    AppBottomNavItem(
      icon: Icons.rate_review_outlined,
      activeIcon: Icons.rate_review,
      label: 'Reseñas',
      tab: BottomNavTab.resenas,
    ),
    AppBottomNavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Perfil',
      tab: BottomNavTab.perfil,
    ),
  ];

  const AppBottomNav({
    super.key,
    required this.currentTab,
    required this.onTap,
    this.navItems = items,
  });

  int get _currentIndex =>
      navItems.indexWhere((item) => item.tab == currentTab);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isLargeScreen = screenWidth >= 900;

    final horizontalMargin = isTablet
        ? (isLargeScreen ? screenWidth * 0.20 : screenWidth * 0.15)
        : 16.0;
    final barHeight = isCompact ? 60.0 : (isTablet ? 76.0 : 68.0);
    final iconSize = isCompact ? 20.0 : (isTablet ? 26.0 : 22.0);
    final fontSize = isCompact ? 11.0 : (isTablet ? 15.0 : 13.0);
    final horizontalPadding = isCompact ? 8.0 : 14.0;
    final verticalPadding = isCompact ? 6.0 : 8.0;

    return SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            margin: EdgeInsets.symmetric(
              horizontal: horizontalMargin,
              vertical: 10,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            constraints: BoxConstraints(
              maxHeight: barHeight,
              minHeight: 52,
              maxWidth: isTablet ? 800 : double.infinity,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface(context),
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
              children: List.generate(navItems.length, (index) {
                final isSelected = index == _currentIndex;
                final item = navItems[index];

                return Flexible(
                  flex: isSelected ? 3 : 1,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onTap(item.tab),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      padding: EdgeInsets.symmetric(
                        horizontal: isSelected ? (isCompact ? 10 : 14) : 6,
                        vertical: isCompact ? 6 : 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary(context)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSelected ? item.activeIcon : item.icon,
                            size: isSelected ? iconSize * 1.1 : iconSize,
                            color: isSelected
                                ? AppColors.onPrimary(context)
                                : AppColors.textSecondary(context),
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                item.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.onPrimary(context),
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
