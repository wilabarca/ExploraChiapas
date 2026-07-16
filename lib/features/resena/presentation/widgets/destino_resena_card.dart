import 'package:explorachiapas/features/resena/domain/entities/DestinoResenaEntity.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/resena_entity.dart';
import 'star_rating.dart';

class DestinoResenaCard extends StatelessWidget {
  final DestinoResenaEntity destino;
  final VoidCallback? onTap;

  const DestinoResenaCard({super.key, required this.destino, this.onTap});

  Color get _tipoColor {
    switch (destino.tipo) {
      case 'Restaurante':
        return const Color(0xFFFF6F00);
      case 'Hotel':
        return const Color(0xFF1565C0);
      case 'Cultura':
        return const Color(0xFF6A1B9A);
      default:
        return const Color(0xFF2E7D32);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✓ LayoutBuilder adapta el card al espacio real disponible
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✓ AspectRatio para imagen proporcional sin overflow
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: destino.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              Container(color: const Color(0xFFD8F5D8)),
                          errorWidget: (_, __, ___) => Container(
                            color: const Color(0xFFD8F5D8),
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.white54,
                            ),
                          ),
                        ),
                      ),
                      if (destino.esPopular)
                        Positioned(
                          top: 8,
                          left: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E7D32),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'DESTINO POPULAR',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // ✓ Expanded + Flexible para que el texto no desborde
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tipo badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _tipoColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            destino.tipo,
                            style: TextStyle(
                              fontSize: 10,
                              color: _tipoColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(height: 6),

                        // ✓ Flexible evita overflow en nombres largos
                        Text(
                          destino.nombre,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B1B1B),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 3),

                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 11,
                              color: Color(0xFF888888),
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                destino.ubicacion,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF888888),
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),

                        // ✓ Spacer empuja calificación al fondo
                        const Spacer(),

                        Row(
                          children: [
                            StarRating(rating: destino.calificacion, size: 12),
                            const SizedBox(width: 4),
                            // ✓ FractionallySizedBox no necesario —
                            // Flexible maneja el texto de reseñas
                            Flexible(
                              child: Text(
                                '${destino.calificacion} · '
                                '${destino.totalResenas} res.',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF888888),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
