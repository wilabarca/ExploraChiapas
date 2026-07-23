import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class PlanificaBanner extends StatelessWidget {
  const PlanificaBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 340;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: EdgeInsets.all(isCompact ? 16 : 20),
          decoration: BoxDecoration(
            // primaryContainer: light=#DCFCE7, dark=#1B4332 — siempre legible
            color: AppColors.primaryContainer(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary(context).withValues(alpha: 0.25),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: AppColors.primary(context),
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'PLANIFICA TU AVENTURA',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary(context),
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Descubre la magia de\nChiapas a tu ritmo.',
                style: TextStyle(
                  fontSize: isCompact ? 19 : 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Creamos una ruta personalizada basada en tus gustos: naturaleza, cultura o gastronomía.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary(context),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/chat'),
                  icon: Icon(
                    Icons.smart_toy_outlined,
                    color: AppColors.onPrimary(context),
                    size: 18,
                  ),
                  label: Text(
                    'Hablar con el guía',
                    style: TextStyle(
                      color: AppColors.onPrimary(context),
                      fontWeight: FontWeight.w600,
                      fontSize: isCompact ? 13 : 15,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary(context),
                    elevation: 0,
                    padding: EdgeInsets.symmetric(
                      vertical: isCompact ? 12 : 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    color: AppColors.primary(context),
                    size: 13,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/chat'),
                      child: Text(
                        'Habla con nuestro guía inteligente',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.primary(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
