import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../negocio/domain/entities/negocio.dart';
import '../../../../core/theme/app_colors.dart';

const List<String> _mesesCortos = [
  'ene',
  'feb',
  'mar',
  'abr',
  'may',
  'jun',
  'jul',
  'ago',
  'sep',
  'oct',
  'nov',
  'dic',
];

String _formatearFecha(DateTime fecha) =>
    '${fecha.day} ${_mesesCortos[fecha.month - 1]}';

/// Tarjeta de un negocio guardado en Favoritos, con el mismo lenguaje
/// visual que [FavoritoDestinoCard] (imagen grande + info + acciones),
/// una vez que el negocio ya fue resuelto vía [ObtenerNegocioPorId].
class FavoritoNegocioCard extends StatelessWidget {
  final Negocio negocio;
  final DateTime guardadoEl;
  final bool procesandoFavorito;
  final VoidCallback? onTap;
  final VoidCallback onQuitarFavorito;

  const FavoritoNegocioCard({
    super.key,
    required this.negocio,
    required this.guardadoEl,
    required this.onQuitarFavorito,
    this.onTap,
    this.procesandoFavorito = false,
  });

  @override
  Widget build(BuildContext context) {
    final tieneImagen = negocio.imagenPrincipal.isNotEmpty;

    return Material(
      color: AppColors.surface(context),
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: AppColors.isDark(context) ? 0.3 : 0.06,
                ),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
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
                            imageUrl: negocio.imagenPrincipal,
                            fit: BoxFit.cover,
                            placeholder: (_, __) =>
                                _buildImagenPlaceholderNegocio(context),
                            errorWidget: (_, __, ___) =>
                                _buildImagenPlaceholderNegocio(context),
                          )
                        : _buildImagenPlaceholderNegocio(context),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: _BotonQuitar(
                        procesando: procesandoFavorito,
                        onTap: procesandoFavorito ? null : onQuitarFavorito,
                      ),
                    ),
                    if (negocio.verificado)
                      Positioned(
                        left: 10,
                        bottom: 10,
                        child: _buildBadgeVerificado(context),
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
                            negocio.nombre,
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
                        _CalificacionChip(valor: negocio.calificacionPromedio),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.storefront_outlined,
                          size: 14,
                          color: AppColors.textSecondary(context),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            negocio.tipoNegocioNombre,
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
                    const SizedBox(height: 10),
                    Text(
                      'Guardado el ${_formatearFecha(guardadoEl)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textHint(context),
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
}

Widget _buildImagenPlaceholderNegocio(BuildContext context) {
  return Container(
    color: AppColors.primaryContainer(context),
    child: Icon(
      Icons.storefront_outlined,
      color: AppColors.primary(context),
      size: 40,
    ),
  );
}

class _BotonQuitar extends StatelessWidget {
  final bool procesando;
  final VoidCallback? onTap;

  const _BotonQuitar({required this.procesando, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: procesando
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.redAccent,
                ),
              )
            : const Icon(Icons.favorite, color: Colors.redAccent, size: 18),
      ),
    );
  }
}

Widget _buildBadgeVerificado(BuildContext context) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: AppColors.primary(context),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.verified_rounded,
          size: 13,
          color: AppColors.onPrimary(context),
        ),
        const SizedBox(width: 5),
        Text(
          'Verificado',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.onPrimary(context),
          ),
        ),
      ],
    ),
  );
}

class _CalificacionChip extends StatelessWidget {
  final double valor;

  const _CalificacionChip({required this.valor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 13, color: Color(0xFFFFC107)),
          const SizedBox(width: 3),
          Text(
            valor.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.primary(context),
            ),
          ),
        ],
      ),
    );
  }
}
