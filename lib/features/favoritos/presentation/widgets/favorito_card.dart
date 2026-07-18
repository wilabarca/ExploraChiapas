import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Tarjeta genérica para un favorito.
///
/// La API de favoritos solo da targetType/targetId/addedAt — el nombre,
/// imagen y calificación deben resolverse aparte (por eso son parámetros
/// opcionales aquí). Si no se pasan, se muestra un placeholder.
class FavoritoCard extends StatelessWidget {
  final String targetType;
  final String targetId;
  final String? nombre;
  final String? imageUrl;
  final double? calificacion;
  final bool procesando;
  final VoidCallback onQuitar;
  final VoidCallback? onTap;

  const FavoritoCard({
    super.key,
    required this.targetType,
    required this.targetId,
    required this.onQuitar,
    this.nombre,
    this.imageUrl,
    this.calificacion,
    this.procesando = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final esNegocio = targetType == 'business';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✓ AspectRatio: imagen con proporción fija sin importar el
            // tamaño de la tarjeta en el grid.
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              Container(color: const Color(0xFFD8F5D8)),
                          errorWidget: (_, __, ___) => Container(
                            color: const Color(0xFFD8F5D8),
                            child: Icon(
                              esNegocio
                                  ? Icons.storefront_outlined
                                  : Icons.image_not_supported_outlined,
                              color: const Color(0xFF2E7D32),
                            ),
                          ),
                        )
                      : Container(
                          color: const Color(0xFFD8F5D8),
                          child: Icon(
                            esNegocio
                                ? Icons.storefront_outlined
                                : Icons.landscape_outlined,
                            color: const Color(0xFF2E7D32),
                            size: 36,
                          ),
                        ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: procesando ? null : onQuitar,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: procesando
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF2E7D32),
                                ),
                              )
                            : const Icon(
                                Icons.favorite,
                                color: Colors.redAccent,
                                size: 18,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Flexible: evita overflow si el nombre es largo.
                  Flexible(
                    child: Text(
                      nombre ?? (esNegocio ? 'Negocio' : 'Destino'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B1B1B),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          esNegocio ? 'Negocio' : 'Destino',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ),
                      if (calificacion != null) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.star,
                            size: 12, color: Color(0xFFFFC107)),
                        const SizedBox(width: 2),
                        Text(
                          calificacion!.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF888888),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}