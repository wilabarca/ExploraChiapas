import 'package:flutter/material.dart';
import '../../domain/entities/negocio.dart';

class NegocioHeader extends StatelessWidget {
  final Negocio negocio;
  final bool esFavorito;
  final VoidCallback onToggleFavorito;

  const NegocioHeader({
    super.key,
    required this.negocio,
    required this.esFavorito,
    required this.onToggleFavorito,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // AspectRatio: imagen principal con proporción fija.
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: Image.network(
                  negocio.imagenPrincipal,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: const Color(0xFFD8F5D8)),
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: onToggleFavorito,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    esFavorito ? Icons.favorite : Icons.favorite_border,
                    color: const Color(0xFF2E7D32),
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text(
                negocio.nombre,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B1B1B),
                ),
              ),
            ),
            if (negocio.verificado)
              const Icon(Icons.verified, color: Color(0xFF2E7D32), size: 20),
          ],
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  negocio.calificacionPromedio.toStringAsFixed(1),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  ' (${negocio.numeroResenas} reseñas)',
                  style: const TextStyle(color: Color(0xFF888888)),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                negocio.tipoNegocioNombre,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}