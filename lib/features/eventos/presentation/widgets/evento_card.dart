import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/envento_entity.dart';

class EventoCard extends StatelessWidget {
  final EventoEntity evento;
  final VoidCallback? onTap;

  const EventoCard({super.key, required this.evento, this.onTap});

  Color get _categoriaColor {
    switch (evento.categoria) {
      case 'Gastronomía':
        return const Color(0xFFFF6F00);
      case 'Cultura':
        return const Color(0xFF6A1B9A);
      case 'Talleres':
        return const Color(0xFF1565C0);
      case 'Festivales':
        return const Color(0xFF00695C);
      default:
        return const Color(0xFF2E7D32);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✓ LayoutBuilder adapta el card al espacio disponible
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✓ AspectRatio mantiene proporción de imagen
                AspectRatio(
                  aspectRatio: 16 / 7,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: evento.imageUrl,
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
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge categoría
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _categoriaColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          evento.categoria,
                          style: TextStyle(
                            fontSize: 12,
                            color: _categoriaColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Título
                      Text(
                        evento.titulo,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B1B1B),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 10),

                      // Fecha y ubicación
                      Row(
                        children: [
                          // ✓ Expanded distribuye el espacio entre fecha y ubicación
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 14,
                                  color: Color(0xFF2E7D32),
                                ),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    evento.fechaFormateada,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF555555),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 14,
                                  color: Color(0xFF2E7D32),
                                ),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    evento.ubicacion,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF555555),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
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
