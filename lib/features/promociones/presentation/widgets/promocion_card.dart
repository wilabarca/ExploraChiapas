import 'package:flutter/material.dart';
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
            // ── Banner superior con ícono + badge de estado ─────────────
            // AspectRatio: mantiene proporción del banner en cualquier ancho.
            AspectRatio(
              aspectRatio: 3.4,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_colorEstado, _colorEstado.withOpacity(0.75)],
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(
                          Icons.local_offer_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                        // FractionallySizedBox: el badge no crece más allá
                        // de un porcentaje razonable del ancho del banner.
                        FractionallySizedBox(
                          widthFactor: 0.42,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
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
                  ],
                ),
              ),
            ),

            // ── Contenido ─────────────────────────────────────────────────
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
                      // Expanded: el nombre del negocio no desborda la card.
                      Expanded(
                        child: Text(
                          promocion.negocioNombre,
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
                  const SizedBox(height: 6),
                  // Flexible: la descripción se recorta si no cabe.
                  Flexible(
                    child: Text(
                      promocion.descripcion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF666666),
                        height: 1.35,
                      ),
                    ),
                  ),
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
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          promocion.precioFormateado,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
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
  }
}
