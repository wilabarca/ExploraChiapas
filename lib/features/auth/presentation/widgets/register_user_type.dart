import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class RegisterUserType extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const RegisterUserType({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TIPO DE USUARIO',
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: AppColors.primary(context),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            // Gris neutro (no verde) para que contraste contra la tarjeta
            // verde clara que lo contiene, igual que los demás campos.
            color: AppColors.surfaceContainer(context),
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selected,
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.primary(context),
              ),
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary(context),
              ),
              dropdownColor: AppColors.surface(context),
              borderRadius: BorderRadius.circular(12),
              items: [
                DropdownMenuItem(
                  value: 'Turista Nacional',
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        color: AppColors.primary(context),
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      const Text('Turista Nacional'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'Turista Extranjero',
                  child: Row(
                    children: [
                      Icon(
                        Icons.flight_outlined,
                        color: AppColors.primary(context),
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      const Text('Turista Extranjero'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'Habitante Local',
                  child: Row(
                    children: [
                      Icon(
                        Icons.home_outlined,
                        color: AppColors.primary(context),
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      const Text('Habitante Local'),
                    ],
                  ),
                ),
              ],
              onChanged: (val) {
                if (val != null) onChanged(val);
              },
            ),
          ),
        ),
      ],
    );
  }
}
