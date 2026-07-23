import 'package:flutter/material.dart';

/// Banner "🔥 Promociones" — llamado a la acción hacia la vista completa
/// de Promociones. Compartido entre Home Turista y Home Local.
///
/// Los textos son parametrizables para que Home Turista pueda seguir
/// pasando las versiones traducidas vía [AppStrings] sin que este widget
/// dependa del idioma activo.
class PromocionesFuegoBanner extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  final String descripcion;
  final String verPromocionesLabel;

  const PromocionesFuegoBanner({
    super.key,
    required this.onTap,
    this.label = 'PROMOCIONES',
    this.descripcion =
        'Descubre descuentos exclusivos de hoteles, restaurantes, tours y más.',
    this.verPromocionesLabel = 'Ver promociones',
  });

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder: adapta proporción y tamaños según el ancho real
    // disponible (no solo el ancho de pantalla).
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 560;

        return GestureDetector(
          onTap: onTap,
          child: AspectRatio(
            // AspectRatio: la card mantiene proporción consistente sin
            // importar el ancho de pantalla.
            aspectRatio: isTablet ? 4.6 / 1.6 : 2.9 / 1.6,
            child: Container(
              padding: EdgeInsets.all(isTablet ? 22 : 18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFF7A45), Color(0xFFD84315)],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -12,
                    bottom: -12,
                    child: Icon(
                      Icons.local_fire_department,
                      size: isTablet ? 100 : 78,
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                  ),
                  Row(
                    children: [
                      // Expanded: el texto ocupa el espacio disponible sin
                      // empujar el ícono.
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  '🔥',
                                  style: TextStyle(fontSize: 15),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: isTablet ? 12 : 10.5,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: isTablet ? 10 : 8),
                            // Flexible: la descripción se recorta si no cabe.
                            Flexible(
                              child: Text(
                                descripcion,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: isTablet ? 14 : 12.5,
                                  color: Colors.white.withValues(alpha: 0.92),
                                  height: 1.35,
                                ),
                              ),
                            ),
                            // Spacer: empuja el enlace hacia el fondo cuando
                            // hay espacio vertical disponible.
                            const Spacer(),
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    verPromocionesLabel,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: isTablet ? 13.5 : 12.5,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.arrow_forward,
                                  size: 15,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
