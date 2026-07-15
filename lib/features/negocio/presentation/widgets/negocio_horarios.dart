import 'package:flutter/material.dart';
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
        const Text(
          'Horarios',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B1B1B),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFEEEEEE)),
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
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1B1B1B),
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
                            ? const Color(0xFFC62828)
                            : const Color(0xFF666666),
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