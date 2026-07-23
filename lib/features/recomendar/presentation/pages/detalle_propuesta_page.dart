import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../destinos/domain/usecases/get_destino_by_id_usecase.dart';
import '../../../destinos/presentation/pages/lugar_detail_page.dart';
import '../../domain/entities/propuesta_destino.dart';
import 'mis_recomendaciones_page.dart' show BadgeEstadoPropuesta;

/// Detalle completo de una propuesta de destino enviada por el usuario.
class DetallePropuestaPage extends StatefulWidget {
  final PropuestaDestino propuesta;

  const DetallePropuestaPage({super.key, required this.propuesta});

  @override
  State<DetallePropuestaPage> createState() => _DetallePropuestaPageState();
}

class _DetallePropuestaPageState extends State<DetallePropuestaPage> {
  final _getDestinoById = getIt<GetDestinoByIdUseCase>();
  bool _cargandoDestino = false;

  Future<void> _verDestinoOficial() async {
    final destinoId = widget.propuesta.createdDestinationId;
    if (destinoId == null || _cargandoDestino) return;

    setState(() => _cargandoDestino = true);

    final resultado = await _getDestinoById(id: destinoId);

    if (!mounted) return;
    setState(() => _cargandoDestino = false);

    resultado.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              failure.message.isNotEmpty
                  ? failure.message
                  : 'No pudimos abrir el destino en este momento.',
            ),
            backgroundColor: AppColors.error(context),
          ),
        );
      },
      (destino) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LugarDetailPage(
              id: destino.id,
              nombre: destino.name,
              categoria: widget.propuesta.categoryName,
              calificacion: destino.averageRating,
              imageUrl: destino.imageUrl ?? '',
              descripcion: destino.description,
              totalResenas: destino.totalReviews,
              targetType: 'destination',
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final propuesta = widget.propuesta;
    final ubicacion = propuesta.location;
    final tieneCoordsValidas =
        !ubicacion.latitude.isNaN && !ubicacion.longitude.isNaN;

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
          'Mi recomendación',
          style: TextStyle(
            color: AppColors.primary(context),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Fotografías ────────────────────────────────
            if (propuesta.images.isNotEmpty)
              SizedBox(
                height: 200,
                child: PageView.builder(
                  itemCount: propuesta.images.length,
                  itemBuilder: (context, index) {
                    final imagenes = [...propuesta.images]
                      ..sort((a, b) => a.order.compareTo(b.order));
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: CachedNetworkImage(
                        imageUrl: imagenes[index].imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: AppColors.primaryContainer(context),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.primaryContainer(context),
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: AppColors.primary(context),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer(context),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Icon(
                    Icons.image_outlined,
                    color: AppColors.primary(context),
                    size: 40,
                  ),
                ),
              ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: Text(
                    propuesta.name,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                ),
                BadgeEstadoPropuesta(status: propuesta.status),
              ],
            ),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer(context),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                propuesta.categoryName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onPrimaryContainer(context),
                ),
              ),
            ),

            const SizedBox(height: 18),

            if (propuesta.description != null &&
                propuesta.description!.isNotEmpty) ...[
              Text(
                'Descripción',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                propuesta.description!,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppColors.textSecondary(context),
                ),
              ),
              const SizedBox(height: 20),
            ],

            Text(
              'Ubicación',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 8),
            if (tieneCoordsValidas) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  height: 140,
                  child: IgnorePointer(
                    // Solo vista previa: reutiliza flutter_map (el mismo
                    // motor de mapas de toda la app), sin gestos, sin
                    // crear una segunda implementación de mapas.
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(
                          ubicacion.latitude,
                          ubicacion.longitude,
                        ),
                        initialZoom: 14,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.none,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.explorachiapas.app',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(
                                ubicacion.latitude,
                                ubicacion.longitude,
                              ),
                              width: 36,
                              height: 36,
                              alignment: Alignment.topCenter,
                              child: const Icon(
                                Icons.location_pin,
                                color: Colors.red,
                                size: 36,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              ubicacion.resumen,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(context),
              ),
            ),
            Text(
              '${ubicacion.latitude.toStringAsFixed(5)}, '
              '${ubicacion.longitude.toStringAsFixed(5)}',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textHint(context),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Enviada el ${_formatearFecha(propuesta.createdAt)}',
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary(context),
              ),
            ),

            const SizedBox(height: 20),

            _ContenidoPorEstado(
              propuesta: propuesta,
              cargandoDestino: _cargandoDestino,
              onVerDestino: _verDestinoOficial,
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    const meses = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    return '${fecha.day} de ${meses[fecha.month - 1]} de ${fecha.year}';
  }
}

class _ContenidoPorEstado extends StatelessWidget {
  final PropuestaDestino propuesta;
  final bool cargandoDestino;
  final VoidCallback onVerDestino;

  const _ContenidoPorEstado({
    required this.propuesta,
    required this.cargandoDestino,
    required this.onVerDestino,
  });

  @override
  Widget build(BuildContext context) {
    switch (propuesta.status) {
      case EstadoPropuestaDestino.pendiente:
        return _Aviso(
          icono: Icons.hourglass_top_outlined,
          color: const Color(0xFFB26A00),
          fondo: const Color(0xFFFFF3D9),
          texto:
              'Tu recomendación está en revisión. Nuestro equipo la '
              'validará antes de publicarla como destino oficial.',
        );

      case EstadoPropuestaDestino.rechazada:
        return _Aviso(
          icono: Icons.cancel_outlined,
          color: const Color(0xFFB3261E),
          fondo: const Color(0xFFFBE4E2),
          texto:
              propuesta.rejectionReason != null &&
                  propuesta.rejectionReason!.isNotEmpty
              ? 'Motivo: ${propuesta.rejectionReason}'
              : 'Esta recomendación fue rechazada.',
        );

      case EstadoPropuestaDestino.aprobada:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Aviso(
              icono: Icons.check_circle_outline,
              color: const Color(0xFF1B7A3D),
              fondo: const Color(0xFFDFF3E4),
              texto:
                  'Esta recomendación fue aprobada y ahora forma parte '
                  'de ExploraChiapas.',
            ),
            if (propuesta.createdDestinationId != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: cargandoDestino ? null : onVerDestino,
                  icon: cargandoDestino
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.arrow_forward, color: Colors.white),
                  label: const Text(
                    'Ver destino',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary(context),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
    }
  }
}

class _Aviso extends StatelessWidget {
  final IconData icono;
  final Color color;
  final Color fondo;
  final String texto;

  const _Aviso({
    required this.icono,
    required this.color,
    required this.fondo,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
