import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../promociones/domain/entities/promocion.dart';

/// Card moderna de promoción para los carruseles del Home (Turista y
/// Local). Usa el mismo [PromocionEntity] que la vista completa de
/// Promociones y el detalle, así que ambos homes comparten exactamente
/// la misma fuente de datos y el mismo diseño.
class HomePromocionCard extends StatelessWidget {
  final PromocionEntity promocion;
  final VoidCallback onTap;

  const HomePromocionCard({
    super.key,
    required this.promocion,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface(context),
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          width: 240,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderSubtle(context)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: AppColors.isDark(context) ? 0.3 : 0.06,
                ),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'promocion-imagen-${promocion.id}',
                child: SizedBox(
                  height: 118,
                  width: double.infinity,
                  child: promocion.tieneImagen
                      ? CachedNetworkImage(
                          imageUrl: promocion.imagenUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => _fallback(context),
                          errorWidget: (_, __, ___) => _fallback(context),
                        )
                      : _fallback(context),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        promocion.titulo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(
                            Icons.storefront_outlined,
                            size: 12,
                            color: AppColors.textSecondary(context),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              promocion.negocioMostrable,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (promocion.descripcionMostrable.isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Flexible(
                          child: Text(
                            promocion.descripcionMostrable,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary(context),
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 11,
                            color: AppColors.textHint(context),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              promocion.rangoFechasFormateado,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textHint(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: promocion.tienePrecio
                              ? AppColors.primaryContainer(context)
                              : AppColors.accentPurpleContainer(context),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          promocion.precioFormateado,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: promocion.tienePrecio
                                ? AppColors.primary(context)
                                : AppColors.accentPurple(context),
                          ),
                        ),
                      ),
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

  Widget _fallback(BuildContext context) {
    return Container(
      color: AppColors.primaryContainer(context),
      alignment: Alignment.center,
      child: Icon(
        Icons.local_offer_outlined,
        size: 30,
        color: AppColors.primary(context),
      ),
    );
  }
}
