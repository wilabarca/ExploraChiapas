import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/propuesta_destino.dart';
import '../providers/mis_recomendaciones_provider.dart';
import 'detalle_propuesta_page.dart';

/// "Mis recomendaciones": estado de las propuestas de destino que el
/// usuario autenticado ha enviado (GET /destination-proposals/mine).
class MisRecomendacionesPage extends StatefulWidget {
  const MisRecomendacionesPage({super.key});

  @override
  State<MisRecomendacionesPage> createState() => _MisRecomendacionesPageState();
}

class _MisRecomendacionesPageState extends State<MisRecomendacionesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MisRecomendacionesProvider>().cargar();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface(context),
      appBar: AppBar(
        backgroundColor: AppColors.surface(context),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primary(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Mis recomendaciones',
          style: TextStyle(
            color: AppColors.primary(context),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Consumer<MisRecomendacionesProvider>(
        builder: (context, provider, _) {
          if (provider.status == MisRecomendacionesStatus.loading ||
              provider.status == MisRecomendacionesStatus.idle) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.status == MisRecomendacionesStatus.error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 44,
                      color: AppColors.error(context),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      provider.errorMessage ??
                          'No pudimos cargar tus recomendaciones.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary(context)),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: provider.cargar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary(context),
                      ),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.propuestas.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.explore_outlined,
                      size: 48,
                      color: AppColors.textHint(context),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Aún no has recomendado ningún lugar.',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Cuando envíes una recomendación, su estado '
                      'aparecerá aquí.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.cargar,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.propuestas.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final propuesta = provider.propuestas[index];
                return _PropuestaCard(
                  propuesta: propuesta,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          DetallePropuestaPage(propuesta: propuesta),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _PropuestaCard extends StatelessWidget {
  final PropuestaDestino propuesta;
  final VoidCallback onTap;

  const _PropuestaCard({required this.propuesta, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final foto = propuesta.fotoPrincipal;

    return Material(
      color: AppColors.background(context),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: foto != null
                    ? CachedNetworkImage(
                        imageUrl: foto.imageUrl,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          width: 72,
                          height: 72,
                          color: AppColors.primaryContainer(context),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          width: 72,
                          height: 72,
                          color: AppColors.primaryContainer(context),
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: AppColors.primary(context),
                          ),
                        ),
                      )
                    : Container(
                        width: 72,
                        height: 72,
                        color: AppColors.primaryContainer(context),
                        child: Icon(
                          Icons.image_outlined,
                          color: AppColors.primary(context),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      propuesta.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      [
                        propuesta.categoryName,
                        if (propuesta.location.municipality != null)
                          propuesta.location.municipality!,
                      ].join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatearFecha(propuesta.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textHint(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    BadgeEstadoPropuesta(status: propuesta.status),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.textHint(context)),
            ],
          ),
        ),
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    const meses = [
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
    return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}';
  }
}

/// Insignia de estado reutilizada en la lista y en el detalle.
class BadgeEstadoPropuesta extends StatelessWidget {
  final EstadoPropuestaDestino status;

  const BadgeEstadoPropuesta({required this.status});

  @override
  Widget build(BuildContext context) {
    late final Color color;
    late final Color fondo;
    late final String texto;
    late final IconData icono;

    switch (status) {
      case EstadoPropuestaDestino.pendiente:
        color = const Color(0xFFB26A00);
        fondo = const Color(0xFFFFF3D9);
        texto = 'En revisión';
        icono = Icons.hourglass_top_outlined;
        break;
      case EstadoPropuestaDestino.aprobada:
        color = const Color(0xFF1B7A3D);
        fondo = const Color(0xFFDFF3E4);
        texto = 'Aprobada';
        icono = Icons.check_circle_outline;
        break;
      case EstadoPropuestaDestino.rechazada:
        color = const Color(0xFFB3261E);
        fondo = const Color(0xFFFBE4E2);
        texto = 'Rechazada';
        icono = Icons.cancel_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            texto,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
