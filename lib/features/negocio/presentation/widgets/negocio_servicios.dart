import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/negocio_servicio.dart';

class NegocioServicios extends StatelessWidget {
  final List<NegocioServicio> servicios;

  const NegocioServicios({super.key, required this.servicios});

  @override
  Widget build(BuildContext context) {
    if (servicios.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Servicios',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: 10),
        // Wrap: los chips fluyen según el ancho disponible.
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: servicios.map((s) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.borderSubtle(context),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 14,
                    color: AppColors.primary(context),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    s.nombre,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
