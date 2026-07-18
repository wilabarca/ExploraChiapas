import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/promocion.dart';

class PromocionCard extends StatelessWidget {
  final PromocionEntity promocion;
  final VoidCallback? onTap;

  const PromocionCard({super.key, required this.promocion, this.onTap});

  Color get _colorEstado {
    switch (promocion.estado) {
      case PromocionEstado.vigente:
        return const Color(0xFF2E7D32);
      case PromocionEstado.proxima:
        return const Color(0xFF1565C0);
      case PromocionEstado.finalizada:
        return const Color(0xFF9E9E9E);
    }
  }

  String get _labelEstado {
    switch (promocion.estado) {
      case PromocionEstado.vigente:
        return 'Vigente';
      case PromocionEstado.proxima:
        return 'Próxima';
      case PromocionEstado.finalizada:
        return 'Finalizada';
    }
  }

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder: adapta tamaños de texto/badges al ancho real de la
    // celda del grid en la que vive esta card.
    return LayoutBuilder(
      builder: (context, constraints) {
        final compacta = constraints.maxWidth < 200;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Banner superior: imagen real si existe, degradado si no ──
                // AspectRatio: mantiene proporción del banner en cualquier
                // ancho de card.
                AspectRatio(
                  aspectRatio: 3.4,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (promocion.tieneImagen)
                        CachedNetworkImage(
                          imageUrl: promocion.imagenUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              Container(color: _colorEstado.withOpacity(0.3)),
                          errorWidget: (_, __, ___) =>
                              _BannerDegradado(color: _colorEstado),
                        )
                      else
                        _BannerDegradado(color: _colorEstado),

                      // Oscurece la parte inferior para que el badge sea
                      // legible sobre cualquier imagen.
                      if (promocion.tieneImagen)
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.35),
                                ],
                                stops: const [0.5, 1.0],
                              ),
                            ),
                          ),
                        ),

                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(
                              Icons.local_offer_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                            // FractionallySizedBox: el badge no crece más
                            // allá de un porcentaje razonable del ancho.
                            FractionallySizedBox(
                              widthFactor: compacta ? 0.55 : 0.42,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.28),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _labelEstado,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Contenido ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.storefront_outlined,
                            size: 13,
                            color: Color(0xFF999999),
                          ),
                          const SizedBox(width: 4),
                          // Expanded: el nombre del negocio no desborda.
                          Expanded(
                            child: Text(
                              promocion.negocioMostrable,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF999999),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        promocion.titulo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B1B1B),
                        ),
                      ),
                      if (promocion.descripcionMostrable.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        // Flexible: la descripción se recorta si no cabe.
                        Flexible(
                          child: Text(
                            promocion.descripcionMostrable,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF666666),
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      // Wrap: fecha y precio se acomodan sin desbordar en
                      // pantallas angostas.
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 12,
                                color: Color(0xFF888888),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                promocion.rangoFechasFormateado,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF888888),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: promocion.tienePrecio
                                  ? const Color(0xFFE8F5E9)
                                  : const Color(0xFFEDE7F6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              promocion.precioFormateado,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: promocion.tienePrecio
                                    ? const Color(0xFF2E7D32)
                                    : const Color(0xFF6A1B9A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Banner de respaldo cuando no hay imagenUrl (o falla al cargar) ─────────
class _BannerDegradado extends StatelessWidget {
  final Color color;

  const _BannerDegradado({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withOpacity(0.75)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            bottom: -8,
            child: Icon(
              Icons.local_offer,
              size: 56,
              color: Colors.white.withOpacity(0.15),
            ),
          ),
        ],
      ),
    );
  }
}
