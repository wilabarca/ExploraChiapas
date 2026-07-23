import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/theme/app_colors.dart';

/// Tarjeta compacta de un favorito, usada en la vista "General" (grid
/// con destinos y negocios mezclados).
///
/// La API de favoritos solo da targetType/targetId/addedAt — el nombre,
/// imagen y calificación deben resolverse aparte (por eso son parámetros
/// opcionales aquí). Si no se pasan, se muestra un placeholder — nunca
/// un ícono de imagen rota.
class FavoritoCard extends StatelessWidget {
  final String targetType;
  final String targetId;
  final String? nombre;
  final String? subtitulo;
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
    this.subtitulo,
    this.imageUrl,
    this.calificacion,
    this.procesando = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final esNegocio = targetType == 'business';
    final tieneImagen = imageUrl != null && imageUrl!.isNotEmpty;

    return Material(
      color: AppColors.surface(context),
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 4 / 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    tieneImagen
                        ? CachedNetworkImage(
                            imageUrl: imageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) =>
                                _buildPlaceholder(context, esNegocio),
                            errorWidget: (_, __, ___) =>
                                _buildPlaceholder(context, esNegocio),
                          )
                        : _buildPlaceholder(context, esNegocio),
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
                                    color: Colors.redAccent,
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
                    Text(
                      nombre ?? (esNegocio ? 'Negocio' : 'Destino'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer(context),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              subtitulo ?? (esNegocio ? 'Negocio' : 'Destino'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary(context),
                              ),
                            ),
                          ),
                        ),
                        if (calificacion != null) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.star,
                            size: 12,
                            color: Color(0xFFFFC107),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            calificacion!.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary(context),
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
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context, bool esNegocio) {
    return Container(
      color: AppColors.primaryContainer(context),
      child: Icon(
        esNegocio ? Icons.storefront_outlined : Icons.landscape_outlined,
        color: AppColors.primary(context),
      ),
    );
  }
}
