import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class DestinoCard extends StatelessWidget {
  final String nombre;
  final String categoria;
  final double calificacion;
  final String? imageUrl;
  final bool esFavorito;
  final bool esSostenible;
  final VoidCallback? onTap;
  final VoidCallback? onFavoritoTap;
  final double? distanciaKm;

  const DestinoCard({
    super.key,
    required this.nombre,
    required this.categoria,
    required this.calificacion,
    this.imageUrl,
    this.esFavorito = false,
    this.esSostenible = false,
    this.onTap,
    this.onFavoritoTap,
    this.distanciaKm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: AppColors.isDark(context) ? 0.3 : 0.07,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: _buildImage(context),
                  ),
                  if (esFavorito || onFavoritoTap != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: onFavoritoTap,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            esFavorito ? Icons.favorite : Icons.favorite_border,
                            color: esFavorito ? Colors.red : Colors.grey,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  if (esSostenible)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary(context),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.eco,
                              color: AppColors.onPrimary(context),
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Eco',
                              style: TextStyle(
                                color: AppColors.onPrimary(context),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombre,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary(context),
                        ),
                        maxLines: distanciaKm != null ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (distanciaKm == null) const Spacer(),
                      if (distanciaKm != null) const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              categoria,
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary(context),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            calificacion.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                          const SizedBox(width: 3),
                          const Icon(
                            Icons.star,
                            size: 11,
                            color: Color(0xFFFFC107),
                          ),
                        ],
                      ),
                      if (distanciaKm != null) ...[
                        const SizedBox(height: 8),
                        _buildTransportRow(context),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransportRow(BuildContext context) {
    final km = distanciaKm!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _TiempoChip(icono: Icons.directions_car, minutos: km * 1.4),
        _TiempoChip(icono: Icons.two_wheeler, minutos: km * 1.0),
        _TiempoChip(icono: Icons.directions_walk, minutos: km * 12.0),
      ],
    );
  }

  Widget _buildImage(BuildContext context) {
    final normalizedImageUrl = imageUrl?.trim();

    if (normalizedImageUrl == null || normalizedImageUrl.isEmpty) {
      return _buildPlaceholder(context);
    }

    return CachedNetworkImage(
      imageUrl: normalizedImageUrl,
      height: 130,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (_, _) => _buildPlaceholder(context),
      errorWidget: (_, _, _) => _buildPlaceholder(context),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      height: 130,
      width: double.infinity,
      color: AppColors.primaryContainer(context),
      child: Center(
        child: Icon(
          Icons.landscape_outlined,
          size: 42,
          color: AppColors.primary(context),
        ),
      ),
    );
  }
}

class _TiempoChip extends StatelessWidget {
  final IconData icono;
  final double minutos;

  const _TiempoChip({required this.icono, required this.minutos});

  String get _texto {
    final t = minutos.round().clamp(1, 9999);
    if (t < 60) return '$t m';
    final h = t ~/ 60;
    final m = t % 60;
    return m == 0 ? '${h}h' : '${h}h${m}m';
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.textSecondary(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, size: 13, color: color),
        const SizedBox(height: 1),
        Text(_texto, style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
