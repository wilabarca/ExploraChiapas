import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RestauranteItem extends StatelessWidget {
  final String nombre;
  final double calificacion;
  final double distanciaKm;
  final String descripcion;
  final String imageUrl;

  const RestauranteItem({
    super.key,
    required this.nombre,
    required this.calificacion,
    required this.distanciaKm,
    required this.descripcion,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                  width: 70,
                  height: 70,
                  color: const Color(0xFFD8F5D8)),
              errorWidget: (_, __, ___) => Container(
                width: 70,
                height: 70,
                color: const Color(0xFFD8F5D8),
                child: const Icon(Icons.restaurant, color: Colors.white54),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B1B1B),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star,
                        color: Color(0xFFFFC107), size: 13),
                    const SizedBox(width: 3),
                    Text(
                      '$calificacion  •  $distanciaKm km de ti',
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF888888)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  descripcion,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF666666),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}