import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/resenas_feed_provider.dart';
import '../utils/resena_display_utils.dart';
import 'resena_avatar.dart';
import 'star_rating.dart';

/// Tarjeta de reseña para el feed general: encabezado con foto y nombre
/// del lugar/negocio + categoría, y debajo el contenido de la reseña
/// (avatar, autor, fecha, estrellas, comentario completo). Marca "Tú"
/// cuando la reseña pertenece al usuario autenticado.
class ResenaFeedCard extends StatelessWidget {
  final ResenaFeedItem item;
  final String categoriaNombre;
  final VoidCallback onTap;

  const ResenaFeedCard({
    super.key,
    required this.item,
    required this.categoriaNombre,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final resena = item.resena;
    final miId = context.watch<AuthProvider>().usuario?.id;
    final esMia = miId != null && miId == resena.userId;

    return Material(
      color: AppColors.surface(context),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderSubtle(context)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: AppColors.isDark(context) ? 0.25 : 0.05,
                ),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Encabezado: foto + nombre del lugar + categoría ─────────
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child:
                          item.lugarImageUrl != null &&
                              item.lugarImageUrl!.isNotEmpty
                          ? Image.network(
                              item.lugarImageUrl!,
                              width: 44,
                              height: 44,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _placeholder(context),
                            )
                          : _placeholder(context),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.lugarNombre,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer(context),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              categoriaNombre,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (esMia)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary(
                            context,
                          ).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Tú',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary(context),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Divider(height: 1),
              ),
              // ── Cuerpo: avatar + autor + fecha + estrellas + comentario ──
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ResenaAvatar(resena: resena, radius: 16),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  esMia
                                      ? 'Tú'
                                      : (resena.userName ??
                                            'Viajero ExploraChiapas'),
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary(context),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              StarRating(
                                rating: resena.rating.toDouble(),
                                size: 12,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            ResenaDisplayUtils.tiempoRelativo(resena.createdAt),
                            style: TextStyle(
                              fontSize: 10.5,
                              color: AppColors.textHint(context),
                            ),
                          ),
                          if (resena.comment != null &&
                              resena.comment!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              resena.comment!,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary(context),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ],
                      ),
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

  Widget _placeholder(BuildContext context) => Container(
    width: 44,
    height: 44,
    color: AppColors.primaryContainer(context),
    child: Icon(
      Icons.place_outlined,
      color: AppColors.primary(context),
      size: 20,
    ),
  );
}
