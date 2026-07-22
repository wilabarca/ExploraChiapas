import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../negocio/domain/entities/negocio.dart';
import '../../../negocio/domain/usecases/obtener_negocio_por_id.dart';
import '../../domain/entities/promocion.dart';
import 'promociones_page.dart';

/// Vista de detalle de una promoción individual. Reutiliza el mismo
/// [PromocionEntity] que la lista completa de Promociones y los
/// carruseles del Home, así que llega con toda la información real del
/// backend sin necesidad de otra llamada a la API.
///
/// La dirección del negocio no viene incluida en la promoción — se
/// resuelve aparte vía [ObtenerNegocioPorId]. Si el negocio ya no existe
/// o la resolución falla, la sección de dirección simplemente se omite
/// (nunca se inventa un dato ni se rompe la pantalla).
class DetallePromocionPage extends StatefulWidget {
  final PromocionEntity promocion;

  const DetallePromocionPage({super.key, required this.promocion});

  @override
  State<DetallePromocionPage> createState() => _DetallePromocionPageState();
}

class _DetallePromocionPageState extends State<DetallePromocionPage> {
  Negocio? _negocio;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolverNegocio());
  }

  Future<void> _resolverNegocio() async {
    try {
      final result = await getIt<ObtenerNegocioPorId>()(
        widget.promocion.negocioId,
      );
      if (!mounted) return;
      result.fold(
        (failure) {}, // negocio eliminado/inexistente: se omite la dirección
        (negocio) => setState(() => _negocio = negocio),
      );
    } catch (_) {
      // Excepción inesperada: la pantalla sigue funcionando sin dirección.
    }
  }

  Color _colorEstado(BuildContext context) {
    switch (widget.promocion.estado) {
      case PromocionEstado.vigente:
        return AppColors.primary(context);
      case PromocionEstado.proxima:
        return const Color(0xFF1565C0);
      case PromocionEstado.finalizada:
        return AppColors.textHint(context);
    }
  }

  String get _labelEstado {
    switch (widget.promocion.estado) {
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
    final promocion = widget.promocion;
    final size = MediaQuery.sizeOf(context);
    final colorEstado = _colorEstado(context);

    return Scaffold(
      backgroundColor: AppColors.surface(context),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: size.height * 0.34,
            pinned: true,
            backgroundColor: AppColors.surface(context),
            leading: _CircleButton(
              icon: Icons.arrow_back,
              onTap: () => Navigator.pop(context),
            ),
            actions: [
              _CircleButton(
                icon: Icons.share_outlined,
                tooltip: 'Compartir',
                onTap: () {
                  Share.share(
                    '¡${promocion.titulo} en ${promocion.negocioMostrable}!\n'
                    '${promocion.descripcionMostrable}\n#ExploraChiapas',
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'promocion-imagen-${promocion.id}',
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (promocion.tieneImagen)
                      CachedNetworkImage(
                        imageUrl: promocion.imagenUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            _ImagenFallback(color: colorEstado),
                        errorWidget: (_, __, ___) =>
                            _ImagenFallback(color: colorEstado),
                      )
                    else
                      _ImagenFallback(color: colorEstado),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.35),
                          ],
                          stops: const [0.6, 1.0],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: colorEstado.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _labelEstado,
                      style: TextStyle(
                        fontSize: 13,
                        color: colorEstado,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    promocion.titulo,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(context),
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _InfoChip(
                        icon: Icons.calendar_today_outlined,
                        label: promocion.rangoFechasFormateado,
                      ),
                      _InfoChip(
                        icon: Icons.storefront_outlined,
                        label: promocion.negocioMostrable,
                      ),
                      _InfoChip(
                        icon: promocion.tienePrecio
                            ? Icons.sell_outlined
                            : Icons.card_giftcard_outlined,
                        label: promocion.precioFormateado,
                        destacado: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Divider(color: AppColors.borderSubtle(context)),

                  const SizedBox(height: 20),

                  Text(
                    'Acerca de la promoción',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(context),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    promocion.descripcionMostrable.isNotEmpty
                        ? promocion.descripcionMostrable
                        : 'Esta promoción aún no tiene una descripción disponible.',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary(context),
                      height: 1.7,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Divider(color: AppColors.borderSubtle(context)),

                  const SizedBox(height: 20),

                  Text(
                    'Ofrecido por',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(context),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer(context),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.storefront_outlined,
                          color: AppColors.primary(context),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              promocion.negocioMostrable,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary(context),
                              ),
                            ),
                            Text(
                              'Negocio afiliado',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primary(context),
                              ),
                            ),
                            // La dirección solo se muestra si se logró
                            // resolver el negocio — nunca se inventa.
                            if (_negocio != null &&
                                _negocio!.direccion.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 15,
                                    color: AppColors.textSecondary(context),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      _negocio!.direccion,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary(context),
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: FractionallySizedBox(
            widthFactor: 1.0,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 54),
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        PromocionesPage(negocioId: promocion.negocioId),
                  ),
                ),
                icon: Icon(
                  Icons.local_offer_outlined,
                  color: AppColors.primary(context),
                ),
                label: Text(
                  'Ver más promociones de ${promocion.negocioMostrable}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.primary(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primary(context)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ImagenFallback extends StatelessWidget {
  final Color color;

  const _ImagenFallback({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withValues(alpha: 0.75)],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.local_offer,
          size: 64,
          color: Colors.white.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  const _CircleButton({required this.icon, required this.onTap, this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.textPrimary(context), size: 20),
        tooltip: tooltip,
        onPressed: onTap,
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool destacado;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.destacado = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = destacado
        ? AppColors.primary(context)
        : AppColors.textSecondary(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: destacado
            ? AppColors.primaryContainer(context)
            : AppColors.background(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: destacado ? FontWeight.w700 : FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
