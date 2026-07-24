import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../negocio/domain/entities/negocio.dart';

/// Tarjeta compacta de negocio para el carrusel horizontal del Home.
/// Antes desbordaba (11px) cuando el negocio tenía `precioDesde`, porque
/// el contenido de texto (nombre de 2 líneas + calificación + precio) no
/// cabía en la altura fija que le daba el `SizedBox` contenedor — Flutter
/// mostraba entonces su franja de advertencia amarilla/negra por
/// defecto, que fácilmente se confunde con "un color amarillo en el
/// diseño" aunque no es un color elegido, es el aviso de error de
/// Flutter. Se corrige dando alto explícito y suficiente a cada línea
/// (sin `Expanded`/`Spacer` peleando por espacio) y ajustando la altura
/// del `SizedBox` que envuelve la lista en `home_turista_page.dart` /
/// `home_local_page.dart`.
class NegocioHomeCard extends StatefulWidget {
  final Negocio negocio;
  final VoidCallback onTap;

  const NegocioHomeCard({
    super.key,
    required this.negocio,
    required this.onTap,
  });

  /// Altura total recomendada para el `SizedBox` que envuelve la lista
  /// horizontal — con margen suficiente para el caso más alto (nombre de
  /// 2 líneas + calificación + precio).
  static const double alturaRecomendada = 236;

  @override
  State<NegocioHomeCard> createState() => _NegocioHomeCardState();
}

class _NegocioHomeCardState extends State<NegocioHomeCard> {
  bool _presionado = false;

  @override
  Widget build(BuildContext context) {
    final negocio = widget.negocio;
    return Listener(
      onPointerDown: (_) => setState(() => _presionado = true),
      onPointerUp: (_) => setState(() => _presionado = false),
      onPointerCancel: (_) => setState(() => _presionado = false),
      child: AnimatedScale(
        scale: _presionado ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            width: 176,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: AppColors.isDark(context) ? 0.3 : 0.06,
                  ),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: negocio.imagenPrincipal,
                    height: 122,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => _placeholder(context),
                    errorWidget: (_, __, ___) => _placeholder(context),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(11, 10, 11, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (negocio.tipoNegocioNombre.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer(context),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            negocio.tipoNegocioNombre,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary(context),
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                      Text(
                        negocio.nombre,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary(context),
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 13,
                            color: Color(0xFFFFC107),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            negocio.calificacionPromedio.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '(${negocio.numeroResenas})',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: AppColors.textHint(context),
                            ),
                          ),
                        ],
                      ),
                      if (negocio.precioDesde != null) ...[
                        const SizedBox(height: 5),
                        Text(
                          'Desde \$${negocio.precioDesde!.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary(context),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _placeholder(BuildContext context) => Container(
    height: 122,
    color: AppColors.primaryContainer(context),
    child: Icon(
      Icons.storefront_outlined,
      size: 34,
      color: AppColors.primary(context),
    ),
  );
}
