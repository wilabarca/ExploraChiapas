import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/propuesta_destino.dart';

class PropuestaCard extends StatelessWidget {
  final PropuestaDestino propuesta;
  final VoidCallback onTap;

  const PropuestaCard({super.key, required this.propuesta, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final primeraFoto = propuesta.images.isNotEmpty
        ? propuesta.images.first.imageUrl
        : null;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Row(
          children: [
            // ── Foto ────────────────────────────────────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: primeraFoto != null
                  ? CachedNetworkImage(
                      imageUrl: primeraFoto,
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        width: 90,
                        height: 90,
                        color: cs.surfaceContainer,
                        child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        width: 90,
                        height: 90,
                        color: cs.surfaceContainer,
                        child: Icon(Icons.place_outlined,
                            color: cs.onSurface.withValues(alpha: 0.3), size: 32),
                      ),
                    )
                  : Container(
                      width: 90,
                      height: 90,
                      color: cs.surfaceContainer,
                      child: Icon(Icons.place_outlined,
                          color: cs.onSurface.withValues(alpha: 0.3), size: 32),
                    ),
            ),

            // ── Info ─────────────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      propuesta.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (propuesta.categoryName != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        propuesta.categoryName!,
                        style: TextStyle(
                            fontSize: 12,
                            color: cs.primary,
                            fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (propuesta.location != null) ...[
                      const SizedBox(height: 2),
                      Row(children: [
                        Icon(Icons.location_on_outlined,
                            size: 12, color: cs.onSurface.withValues(alpha: 0.5)),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            propuesta.location!.municipality,
                            style: TextStyle(
                                fontSize: 12,
                                color: cs.onSurface.withValues(alpha: 0.6)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ]),
                    ],
                    if (propuesta.createdAt != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        _fechaCorta(propuesta.createdAt!),
                        style: TextStyle(
                            fontSize: 11,
                            color: cs.onSurface.withValues(alpha: 0.4)),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // ── Estado ───────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _BadgeEstado(status: propuesta.status),
            ),
          ],
        ),
      ),
    );
  }

  String _fechaCorta(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year}';
  }
}

class _BadgeEstado extends StatelessWidget {
  final String status;
  const _BadgeEstado({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String etiqueta;

    switch (status) {
      case 'aprobada':
        bg = const Color(0xFFE8F5E9);
        fg = const Color(0xFF2E7D32);
        etiqueta = 'Aprobada';
        break;
      case 'rechazada':
        bg = const Color(0xFFFFEBEE);
        fg = const Color(0xFFC62828);
        etiqueta = 'Rechazada';
        break;
      default:
        bg = const Color(0xFFFFF8E1);
        fg = const Color(0xFFF57F17);
        etiqueta = 'En revisión';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        etiqueta,
        style: TextStyle(
            color: fg, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
