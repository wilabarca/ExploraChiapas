import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/propuesta_destino.dart';

class DetallePropuestaPage extends StatelessWidget {
  final PropuestaDestino propuesta;

  const DetallePropuestaPage({super.key, required this.propuesta});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final primeraFoto = propuesta.images.isNotEmpty
        ? propuesta.images.first.imageUrl
        : null;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: primeraFoto != null ? 220 : 0,
            pinned: true,
            title: Text(
              propuesta.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            flexibleSpace: primeraFoto != null
                ? FlexibleSpaceBar(
                    background: CachedNetworkImage(
                      imageUrl: primeraFoto,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: cs.surfaceContainer,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: cs.surfaceContainer,
                        child: Icon(Icons.image_not_supported_outlined,
                            color: cs.onSurface.withValues(alpha: 0.3), size: 48),
                      ),
                    ),
                  )
                : null,
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Estado ────────────────────────────────────────────────
                  _ChipEstado(status: propuesta.status),
                  const SizedBox(height: 16),

                  // ── Motivo de rechazo ─────────────────────────────────────
                  if (propuesta.status == 'rechazada' &&
                      propuesta.rejectionReason != null) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cs.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline,
                              color: cs.onErrorContainer, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Motivo de rechazo',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: cs.onErrorContainer,
                                        fontSize: 13)),
                                const SizedBox(height: 4),
                                Text(propuesta.rejectionReason!,
                                    style: TextStyle(
                                        color: cs.onErrorContainer,
                                        fontSize: 13,
                                        height: 1.4)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Destino oficial aprobado ───────────────────────────────
                  if (propuesta.status == 'aprobada') ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.verified, color: cs.primary, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Esta recomendación fue aprobada y ahora forma '
                              'parte de ExploraChiapas.',
                              style: TextStyle(
                                  color: cs.onPrimaryContainer,
                                  fontSize: 13,
                                  height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (propuesta.createdDestinationId != null) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            '/destino/${propuesta.createdDestinationId}',
                            arguments: {'id': propuesta.createdDestinationId},
                          ),
                          icon: const Icon(Icons.open_in_new, size: 16),
                          label: const Text('Ver destino oficial'),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                  ],

                  // ── Nombre ────────────────────────────────────────────────
                  Text(
                    propuesta.name,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  if (propuesta.categoryName != null)
                    Text(
                      propuesta.categoryName!,
                      style: TextStyle(
                          fontSize: 14,
                          color: cs.primary,
                          fontWeight: FontWeight.w500),
                    ),
                  const SizedBox(height: 16),

                  // ── Descripción ───────────────────────────────────────────
                  if (propuesta.description != null) ...[
                    _SeccionTitulo('Descripción'),
                    const SizedBox(height: 6),
                    Text(
                      propuesta.description!,
                      style: TextStyle(
                          fontSize: 14,
                          color: cs.onSurface.withValues(alpha: 0.8),
                          height: 1.5),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── Ubicación ─────────────────────────────────────────────
                  if (propuesta.location != null) ...[
                    _SeccionTitulo('Ubicación'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.location_on, color: cs.primary, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${propuesta.location!.municipality}, '
                                  '${propuesta.location!.state}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600, fontSize: 14),
                                ),
                                if (propuesta.location!.address.isNotEmpty)
                                  Text(
                                    propuesta.location!.address,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            cs.onSurface.withValues(alpha: 0.6)),
                                  ),
                                Text(
                                  '${propuesta.location!.latitude.toStringAsFixed(6)}, '
                                  '${propuesta.location!.longitude.toStringAsFixed(6)}',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: cs.onSurface.withValues(alpha: 0.4)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── Fotografías ───────────────────────────────────────────
                  if (propuesta.images.isNotEmpty) ...[
                    _SeccionTitulo(
                        'Fotografías (${propuesta.images.length})'),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 120,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: propuesta.images.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          final img = propuesta.images[i];
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl: img.imageUrl,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                width: 120,
                                color: cs.surfaceContainer,
                                child: const Center(
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2)),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                width: 120,
                                color: cs.surfaceContainer,
                                child: Icon(Icons.image_not_supported_outlined,
                                    color: cs.onSurface.withValues(alpha: 0.3)),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── Fecha de envío ────────────────────────────────────────
                  if (propuesta.createdAt != null) ...[
                    _SeccionTitulo('Fecha de envío'),
                    const SizedBox(height: 4),
                    Text(
                      _formatearFecha(propuesta.createdAt!),
                      style: TextStyle(
                          fontSize: 14,
                          color: cs.onSurface.withValues(alpha: 0.7)),
                    ),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    const meses = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
    ];
    return '${fecha.day} de ${meses[fecha.month - 1]} de ${fecha.year}';
  }
}

class _SeccionTitulo extends StatelessWidget {
  final String texto;
  const _SeccionTitulo(this.texto);

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
    );
  }
}

class _ChipEstado extends StatelessWidget {
  final String status;
  const _ChipEstado({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String etiqueta;
    IconData icono;

    switch (status) {
      case 'aprobada':
        bg = const Color(0xFFE8F5E9);
        fg = const Color(0xFF2E7D32);
        etiqueta = 'Aprobada';
        icono = Icons.check_circle_outline;
        break;
      case 'rechazada':
        bg = const Color(0xFFFFEBEE);
        fg = const Color(0xFFC62828);
        etiqueta = 'Rechazada';
        icono = Icons.cancel_outlined;
        break;
      default:
        bg = const Color(0xFFFFF8E1);
        fg = const Color(0xFFF57F17);
        etiqueta = 'En revisión';
        icono = Icons.hourglass_empty_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, color: fg, size: 16),
          const SizedBox(width: 6),
          Text(etiqueta,
              style: TextStyle(
                  color: fg, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}
