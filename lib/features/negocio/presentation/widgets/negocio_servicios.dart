import 'package:flutter/material.dart';
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
        const Text(
          'Servicios',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B1B1B),
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
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_outline,
                      size: 14, color: Color(0xFF2E7D32)),
                  const SizedBox(width: 6),
                  Text(
                    s.nombre,
                    style: const TextStyle(fontSize: 12.5, color: Color(0xFF444444)),
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