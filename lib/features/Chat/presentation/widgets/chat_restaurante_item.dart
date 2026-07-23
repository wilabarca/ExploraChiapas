import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/theme/app_colors.dart';

class ChatRestauranteItem extends StatelessWidget {
  final String nombre;
  final String tipo;
  final String precio;
  final String? imageUrl;

  const ChatRestauranteItem({
    super.key,
    required this.nombre,
    required this.tipo,
    required this.precio,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: AppColors.isDark(context) ? 0.3 : 0.05,
            ),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: imageUrl!,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      width: 70,
                      height: 70,
                      color: AppColors.primaryContainer(context),
                    ),
                    errorWidget: (_, __, ___) =>
                        _buildPlaceholderRestaurante(context),
                  )
                : _buildPlaceholderRestaurante(context),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  tipo,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  precio,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.primary(context),
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

Widget _buildPlaceholderRestaurante(BuildContext context) {
  return Container(
    width: 70,
    height: 70,
    color: AppColors.primaryContainer(context),
    child: Icon(Icons.restaurant, color: AppColors.primary(context)),
  );
}
