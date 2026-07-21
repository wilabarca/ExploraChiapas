import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../destinos/domain/entities/destino.dart';
import '../../../../core/theme/app_colors.dart';

const List<String> _mesesCortos = [
  'ene', 'feb', 'mar', 'abr', 'may', 'jun',
  'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
];

String _formatearFecha(DateTime fecha) {
  return '${fecha.day} ${_mesesCortos[fecha.month - 1]}';
}

/// Tarjeta de un destino guardado en Favoritos, con el estilo de lista
/// (imagen grande + info) usado en la vista "Mis Favoritos".
class FavoritoDestinoCard extends StatelessWidget {
  final Destino destino;
  final String categoriaNombre;
  final DateTime guardadoEl;
  final bool procesandoFavorito;
  final VoidCallback onTap;
  final VoidCallback onQuitarFavorito;
  final VoidCallback onPlanificarRuta;

  const FavoritoDestinoCard({
    super.key,
    required this.destino,
    required this.categoriaNombre,
    required this.guardadoEl,
    required this.onTap,
    required this.onQuitarFavorito,
    required this.onPlanificarRuta,
    this.procesandoFavorito = false,
  });

  @override
  Widget build(BuildContext context) {
    final esSostenible = !destino.isSaturated;
    final tieneImagen = (destino.imageUrl ?? '').isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  tieneImagen
                      ? CachedNetworkImage(
                          imageUrl: destino.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              Container(color: const Color(0xFFD8F5D8)),
                          errorWidget: (_, __, ___) => _ImagenPlaceholder(),
                        )
                      : _ImagenPlaceholder(),

                  // Botón de quitar de favoritos.
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: procesandoFavorito ? null : onQuitarFavorito,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: procesandoFavorito
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.redAccent,
                                ),
                              )
                            : const Icon(Icons.favorite,
                                color: Colors.redAccent, size: 18),
                      ),
                    ),
                  ),

                  // Badge de sostenibilidad, abajo a la izquierda.
                  if (esSostenible)
                    Positioned(
                      left: 10,
                      bottom: 10,
                      child: _Badge(
                        icono: Icons.eco,
                        texto: 'Eco-Sostenible',
                      ),
                    ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          destino.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary(context),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _CalificacionChip(valor: destino.averageRating),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.place_outlined,
                          size: 14, color: AppColors.textSecondary(context)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          categoriaNombre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Guardado el ${_formatearFecha(guardadoEl)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textHint(context),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: onPlanificarRuta,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary(context),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Planificar Ruta',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
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

class _ImagenPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFD8F5D8),
      child: const Icon(Icons.landscape_outlined,
          color: Color(0xFF2E7D32), size: 40),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icono;
  final String texto;

  const _Badge({required this.icono, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 13, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            texto,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _CalificacionChip extends StatelessWidget {
  final double valor;

  const _CalificacionChip({required this.valor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 13, color: Color(0xFFFFC107)),
          const SizedBox(width: 3),
          Text(
            valor.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }
}
