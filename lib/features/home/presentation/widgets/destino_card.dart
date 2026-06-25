import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DestinoCard extends StatelessWidget {
  final String nombre;
  final String categoria;
  final double calificacion;
  final String imageUrl;
  final bool esFavorito;

  const DestinoCard({
    super.key,
    required this.nombre,
    required this.categoria,
    required this.calificacion,
    required this.imageUrl,
    this.esFavorito = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
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
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16)),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  height: 130,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) =>
                      Container(height: 130, color: const Color(0xFFD8F5D8)),
                  errorWidget: (_, __, ___) => Container(
                    height: 130,
                    color: const Color(0xFFD8F5D8),
                    child: const Icon(Icons.image_not_supported,
                        color: Colors.white54),
                  ),
                ),
              ),
              if (esFavorito)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite,
                        color: Colors.red, size: 16),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B1B1B),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '$categoria • $calificacion ★',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888888),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}