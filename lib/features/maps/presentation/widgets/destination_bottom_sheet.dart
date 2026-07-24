import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/destination_entity.dart';
import '../../domain/entities/route_info.dart';
import '../../../../core/theme/app_colors.dart';

enum _ModoTransporte { carro, moto, pie, bici }

class DestinationBottomSheet extends StatefulWidget {
  final DestinationEntity destino;
  final RouteInfo? routeInfo;       // driving (carro/moto)
  final RouteInfo? routePie;        // foot
  final RouteInfo? routeBici;       // bike
  final bool esRecomendado;
  final VoidCallback onVerRuta;
  final VoidCallback? onRecalcular;
  final VoidCallback onGuardar;
  final VoidCallback onCerrar;
  final int? durationMinutes;
  final double? distanceKm;

  const DestinationBottomSheet({
    super.key,
    required this.destino,
    this.routeInfo,
    this.routePie,
    this.routeBici,
    this.esRecomendado = false,
    required this.onVerRuta,
    this.onRecalcular,
    required this.onGuardar,
    required this.onCerrar,
    this.durationMinutes,
    this.distanceKm,
  });

  @override
  State<DestinationBottomSheet> createState() => _DestinationBottomSheetState();
}

class _DestinationBottomSheetState extends State<DestinationBottomSheet> {
  _ModoTransporte _modo = _ModoTransporte.carro;

  // Velocidades calibradas con datos reales de Google Maps en Chiapas:
  // - Suchiapa→Corpus Cristi (0.75 km): pie 10 min, bici 2 min
  // - Tuxtla→Chiapa de Corzo (15.1 km): pie 3h 20min, bici 52 min
  // - Tuxtla→San Cristóbal (58.9 km): pie 19h 31min, bici 7h 6min
  int? _tiempoParaModo(_ModoTransporte modo) {
    final driving = widget.routeInfo;
    if (driving == null) return null;
    final distKm = driving.distanceKm;
    final carMin = driving.durationMinutes;
    switch (modo) {
      case _ModoTransporte.carro:
        return carMin;
      case _ModoTransporte.moto:
        return (carMin * 0.90).round();
      case _ModoTransporte.pie:
        // < 30 km terreno plano/urbano: 4.5 km/h
        // >= 30 km montaña/largo: 3.0 km/h (pendientes pronunciadas)
        final velPie = distKm < 30 ? 4.5 : 3.0;
        return (distKm / velPie * 60).round();
      case _ModoTransporte.bici:
        // < 5 km urbano plano: 18 km/h
        // < 30 km semi-plano: 17 km/h
        // >= 30 km montaña/largo: 8.5 km/h
        final velBici = distKm < 5 ? 18.0 : distKm < 30 ? 17.0 : 8.5;
        return (distKm / velBici * 60).round();
    }
  }

  String _distanciaParaModo(_ModoTransporte modo) {
    final driving = widget.routeInfo;
    if (driving == null) return '-- km';
    // Todos los modos muestran la distancia de carretera (la más confiable).
    // A pie y Bici suelen tener rutas más directas pero OSM no las tiene bien
    // mapeadas en Chiapas, así que evitamos inventar datos.
    return driving.distanceText;
  }

  bool get _hayRutasCalculadas => widget.routeInfo != null;

  @override
  Widget build(BuildContext context) {
    final durationModo = _tiempoParaModo(_modo);
    final distanciaLabel = _distanciaParaModo(_modo);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderSubtle(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.destino.nombre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Color(0xFFFFC107),
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.destino.calificacion.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary(context),
                              ),
                            ),
                          ],
                        ),
                        _TipoBadge(tipo: widget.destino.tipo),
                        if (widget.esRecomendado)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary(context),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 11,
                                  color: AppColors.onPrimary(context),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Para ti',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onPrimary(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (widget.destino.esMock)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Muestra',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // Close + eco badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: widget.onCerrar,
                    child: Icon(
                      Icons.close,
                      size: 20,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                  if (widget.destino.esSostenible) ...[
                    const SizedBox(height: 6),
                    Tooltip(
                      message:
                          'Destino con baja afluencia: experiencia tranquila',
                      child: Icon(
                        Icons.eco,
                        color: AppColors.primary(context),
                        size: 24,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Crowd level bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Afluencia actual',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.destino.afluencia > 75)
                        const Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Icon(
                            Icons.warning_amber_rounded,
                            size: 14,
                            color: Colors.orange,
                          ),
                        ),
                      Text(
                        widget.destino.afluencia > 75 ? 'Alta' : 'Normal',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: widget.destino.afluencia > 75
                              ? Colors.orange
                              : AppColors.primary(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: widget.destino.afluencia / 100,
                  minHeight: 6,
                  backgroundColor: AppColors.surfaceContainer(context),
                  valueColor: AlwaysStoppedAnimation(
                    widget.destino.afluencia > 75
                        ? Colors.orange
                        : AppColors.primary(context),
                  ),
                ),
              ),
            ],
          ),

          if (widget.routeInfo != null && widget.onRecalcular != null) ...[
            const SizedBox(height: 14),
            GestureDetector(
              onTap: widget.onRecalcular,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer(context),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(Icons.refresh, size: 15, color: AppColors.primary(context)),
                    const SizedBox(width: 6),
                    Text(
                      'Recalcular ruta',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 12),

          Text(
            widget.destino.descripcion,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary(context),
              height: 1.5,
            ),
          ),

          const SizedBox(height: 20),

          if (_hayRutasCalculadas) ...[
            // Tabs de modo de transporte
            Row(
              children: [
                _ModoTab(
                  icon: Icons.directions_car_outlined,
                  label: 'Carro',
                  activo: _modo == _ModoTransporte.carro,
                  onTap: () => setState(() => _modo = _ModoTransporte.carro),
                ),
                const SizedBox(width: 8),
                _ModoTab(
                  icon: Icons.two_wheeler_outlined,
                  label: 'Moto',
                  activo: _modo == _ModoTransporte.moto,
                  onTap: () => setState(() => _modo = _ModoTransporte.moto),
                ),
                const SizedBox(width: 8),
                _ModoTab(
                  icon: Icons.directions_walk_outlined,
                  label: 'A pie',
                  activo: _modo == _ModoTransporte.pie,
                  onTap: () => setState(() => _modo = _ModoTransporte.pie),
                ),
                const SizedBox(width: 8),
                _ModoTab(
                  icon: Icons.directions_bike_outlined,
                  label: 'Bici',
                  activo: _modo == _ModoTransporte.bici,
                  onTap: () => setState(() => _modo = _ModoTransporte.bici),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (durationModo != null)
                  _InfoChip(
                    icon: Icons.access_time_rounded,
                    label: durationModo >= 60
                        ? '${durationModo ~/ 60} h ${durationModo % 60} min'
                        : '$durationModo min',
                  ),
                if (durationModo != null) const SizedBox(width: 10),
                _InfoChip(
                  icon: Icons.straighten_rounded,
                  label: distanciaLabel,
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.onGuardar,
                  icon: Icon(
                    Icons.bookmark_border,
                    color: AppColors.primary(context),
                  ),
                  label: Text(
                    'Guardar',
                    style: TextStyle(color: AppColors.primary(context)),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primary(context)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: widget.onVerRuta,
                  icon: Icon(
                    Icons.directions,
                    color: AppColors.onPrimary(context),
                  ),
                  label: Text(
                    'Ver ruta',
                    style: TextStyle(color: AppColors.onPrimary(context)),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary(context),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.share_outlined),
                color: AppColors.textSecondary(context),
                tooltip: 'Compartir',
                onPressed: () {
                  Share.share(
                    '¡Visita ${widget.destino.nombre} en ExploraChiapas!\n${widget.destino.descripcion}',
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer(context),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.primary(context)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModoTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool activo;
  final VoidCallback onTap;
  const _ModoTab({required this.icon, required this.label, required this.activo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: activo ? AppColors.primary(context) : AppColors.surfaceContainer(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: activo ? AppColors.onPrimary(context) : AppColors.textSecondary(context)),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: activo ? AppColors.onPrimary(context) : AppColors.textSecondary(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TipoBadge extends StatelessWidget {
  final String tipo;
  const _TipoBadge({required this.tipo});

  // Softer background colors (same palette, reduced saturation). Claves
  // alineadas con las 6 categorías reales de `/categories?scope=destinos`.
  static const _fondos = {
    'naturaleza': Color(0xFFE8F5E9),
    'cultura': Color(0xFFE3F2FD),
    'gastronomia': Color(0xFFFFF3E0),
    'aventura': Color(0xFFF3E5F5),
    'descanso': Color(0xFFE0F7FA),
    'pueblos magicos': Color(0xFFFCE4EC),
    'arqueologia': Color(0xFFEFEBE9),
  };
  static const _fondosDark = {
    'naturaleza': Color(0xFF1B3A1C),
    'cultura': Color(0xFF0D253A),
    'gastronomia': Color(0xFF3A2200),
    'aventura': Color(0xFF2A0B3A),
    'descanso': Color(0xFF003A40),
    'pueblos magicos': Color(0xFF3A0D24),
    'arqueologia': Color(0xFF2A211D),
  };
  static const _textos = {
    'naturaleza': Color(0xFF43A047),
    'cultura': Color(0xFF1976D2),
    'gastronomia': Color(0xFFEF6C00),
    'aventura': Color(0xFF7B1FA2),
    'descanso': Color(0xFF00838F),
    'pueblos magicos': Color(0xFFAD1457),
    'arqueologia': Color(0xFF6D4C41),
  };
  static const _iconos = {
    'naturaleza': Icons.park_outlined,
    'cultura': Icons.account_balance_outlined,
    'gastronomia': Icons.restaurant_outlined,
    'aventura': Icons.terrain_outlined,
    'descanso': Icons.spa_outlined,
    'pueblos magicos': Icons.location_city_outlined,
    'arqueologia': Icons.temple_hindu_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final fondo = isDark
        ? (_fondosDark[tipo] ?? const Color(0xFF1B3A1C))
        : (_fondos[tipo] ?? const Color(0xFFE8F5E9));
    final texto = _textos[tipo] ?? const Color(0xFF43A047);
    final icono = _iconos[tipo] ?? Icons.place_outlined;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 12, color: texto),
          const SizedBox(width: 4),
          Text(
            tipo[0].toUpperCase() + tipo.substring(1),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: texto,
            ),
          ),
        ],
      ),
    );
  }
}
