import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/negocio_horario.dart';

class NegocioHorarios extends StatelessWidget {
  final List<NegocioHorario> horarios;

  const NegocioHorarios({super.key, required this.horarios});

  @override
  Widget build(BuildContext context) {
    if (horarios.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Horarios',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderSubtle(context)),
          ),
          child: Column(
            children: horarios.map((h) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        h.diaSemana,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                    ),
                    Text(
                      h.cerrado
                          ? 'Cerrado'
                          : '${h.horaApertura ?? '--'} - ${h.horaCierre ?? '--'}',
                      style: TextStyle(
                        fontSize: 13,
                        color: h.cerrado
                            ? AppColors.error(context)
                            : AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
