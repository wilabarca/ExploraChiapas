import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/resena_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import 'star_rating.dart';

/// ⚠️ La API solo devuelve `userId`, no nombre ni foto del usuario
/// (confirmado en el código del backend: los reviews nunca hacen JOIN
/// contra la tabla `usuario`). Por eso no se puede mostrar un nombre
/// real todavía — se distingue a cada autor con un color/identificador
/// consistente en vez de un ícono genérico igual para todos, y se
/// marca "Tú" cuando la reseña es del usuario actual.
class ResenaCard extends StatelessWidget {
  final Resena resena;

  const ResenaCard({super.key, required this.resena});

  static const _coloresAvatar = [
    Color(0xFF2E7D32),
    Color(0xFF1565C0),
    Color(0xFF6A1B9A),
    Color(0xFFEF6C00),
    Color(0xFFC2185B),
    Color(0xFF00838F),
  ];

  Color _colorPorUsuario(String userId) {
    final hash = userId.codeUnits.fold<int>(0, (acc, c) => acc + c);
    return _coloresAvatar[hash % _coloresAvatar.length];
  }

  String _iniciales(String userId) {
    final limpio = userId.replaceAll('-', '');
    return limpio.isEmpty ? '?' : limpio.substring(0, 2).toUpperCase();
  }

  String _tiempoRelativo(DateTime fecha) {
    final diferencia = DateTime.now().difference(fecha);

    if (diferencia.inMinutes < 1) return 'Justo ahora';
    if (diferencia.inMinutes < 60) return 'Hace ${diferencia.inMinutes} min';
    if (diferencia.inHours < 24) return 'Hace ${diferencia.inHours} h';
    if (diferencia.inDays == 1) return 'Ayer';
    if (diferencia.inDays < 7) return 'Hace ${diferencia.inDays} días';
    if (diferencia.inDays < 30) {
      return 'Hace ${(diferencia.inDays / 7).floor()} sem';
    }

    const meses = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
    ];
    return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    final miId = context.watch<AuthProvider>().usuario?.id;
    final esMia = miId != null && miId == resena.userId;
    final colorAvatar = _colorPorUsuario(resena.userId);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: colorAvatar.withValues(alpha: 0.15),
                child: Text(
                  _iniciales(resena.userId),
                  style: TextStyle(
                    color: colorAvatar,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            esMia ? 'Tú' : 'Viajero ExploraChiapas',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        StarRating(rating: resena.rating.toDouble(), size: 13),
                        const SizedBox(width: 6),
                        Text(
                          '· ${_tiempoRelativo(resena.createdAt)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textHint(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (resena.comment != null && resena.comment!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              resena.comment!,
              style: TextStyle(
                fontSize: 13.5,
                color: AppColors.textSecondary(context),
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
