import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ChatRestauranteItem extends StatelessWidget {
  final String nombre;
  final String tipo;
  final String precio;
  final String imageUrl;

  const ChatRestauranteItem({
    super.key,
    required this.nombre,
    required this.tipo,
    required this.precio,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                color: const Color(0xFFD8F5D8),
              ),
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
                const SizedBox(height: 3),
                Text(
                  tipo,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF888888),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  precio,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.w600,
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
