import 'package:flutter/material.dart';
import '../../domain/entities/negocio.dart';

class NegocioInfo extends StatelessWidget {
  final Negocio negocio;

  const NegocioInfo({super.key, required this.negocio});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Descripción',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B1B1B),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          negocio.descripcion,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF555555),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.location_on_outlined,
                size: 18, color: Color(0xFF2E7D32)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                negocio.direccion,
                style: const TextStyle(fontSize: 13.5, color: Color(0xFF444444)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Placeholder de mapa — reemplazar por flutter_map/OSM cuando se
        // integre este feature con el módulo de mapas existente.
        AspectRatio(
          aspectRatio: 16 / 8,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Icon(Icons.map_outlined, size: 36, color: Color(0xFF2E7D32)),
            ),
          ),
        ),
        if (negocio.precioDesde != null) ...[
          const SizedBox(height: 18),
          Row(
            children: [
              const Icon(Icons.sell_outlined, size: 18, color: Color(0xFF2E7D32)),
              const SizedBox(width: 8),
              Text(
                'Desde \$${negocio.precioDesde!.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
        ],
        if (negocio.promocionesVigentes.isNotEmpty) ...[
          const SizedBox(height: 18),
          const Text(
            'Promociones vigentes',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B1B1B),
            ),
          ),
          const SizedBox(height: 8),
          ...negocio.promocionesVigentes.map(
            (promo) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_offer_outlined,
                      size: 15, color: Color(0xFFE65100)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      promo,
                      style: const TextStyle(fontSize: 13, color: Color(0xFFE65100)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}