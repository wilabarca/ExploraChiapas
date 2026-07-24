import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/negocio.dart';

class NegocioInfo extends StatelessWidget {
  final Negocio negocio;

  const NegocioInfo({super.key, required this.negocio});

  @override
  Widget build(BuildContext context) {
    final colorPromo = AppColors.isDark(context)
        ? const Color(0xFFFFCC80)
        : const Color(0xFFE65100);
    final fondoPromo = AppColors.isDark(context)
        ? const Color(0xFF4A2E00)
        : const Color(0xFFFFF3E0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Descripción',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          negocio.descripcion,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary(context),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 18,
              color: AppColors.primary(context),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                negocio.direccion,
                style: TextStyle(
                  fontSize: 13.5,
                  color: AppColors.textSecondary(context),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: AspectRatio(
            aspectRatio: 16 / 8,
            child: negocio.tieneCoordenadasValidas
                ? IgnorePointer(
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(
                          negocio.latitud,
                          negocio.longitud,
                        ),
                        initialZoom: 15,
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
                              point: LatLng(negocio.latitud, negocio.longitud),
                              width: 36,
                              height: 36,
                              alignment: Alignment.topCenter,
                              child: Icon(
                                Icons.location_pin,
                                color: AppColors.primary(context),
                                size: 36,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : Container(
                    color: AppColors.primaryContainer(context),
                    child: Center(
                      child: Icon(
                        Icons.map_outlined,
                        size: 36,
                        color: AppColors.primary(context),
                      ),
                    ),
                  ),
          ),
        ),
        if (negocio.precioDesde != null) ...[
          const SizedBox(height: 18),
          Row(
            children: [
              Icon(
                Icons.sell_outlined,
                size: 18,
                color: AppColors.primary(context),
              ),
              const SizedBox(width: 8),
              Text(
                'Desde \$${negocio.precioDesde!.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary(context),
                ),
              ),
            ],
          ),
        ],
        if (negocio.promocionesVigentes.isNotEmpty) ...[
          const SizedBox(height: 18),
          Text(
            'Promociones vigentes',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          ...negocio.promocionesVigentes.map(
            (promo) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: fondoPromo,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.local_offer_outlined, size: 15, color: colorPromo),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      promo,
                      style: TextStyle(fontSize: 13, color: colorPromo),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
