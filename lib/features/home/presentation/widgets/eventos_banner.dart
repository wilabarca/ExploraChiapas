import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class EventosBanner extends StatelessWidget {
  final VoidCallback? onExplorar;

  const EventosBanner({super.key, this.onExplorar});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 560;
        return AspectRatio(
          aspectRatio: isTablet ? 4.2 / 1.6 : 2.6 / 1.6,
          child: Container(
            padding: EdgeInsets.all(isTablet ? 24 : 18),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer(context),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.primary(context).withValues(alpha: 0.2),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -10,
                  bottom: -10,
                  child: Icon(
                    Icons.fact_check_outlined,
                    size: isTablet ? 90 : 70,
                    color: AppColors.primary(context).withValues(alpha: 0.12),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Descubrir eventos locales próximos',
                      style: TextStyle(
                        fontSize: isTablet ? 20 : 16.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: Text(
                        'Festivales, talleres artesanales y ceremonias '
                        'tradicionales esta semana.',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 12.5,
                          color: AppColors.textSecondary(context),
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: onExplorar,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Explorar',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.primary(context),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward,
                            size: 16,
                            color: AppColors.primary(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
