import 'dart:async';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import 'mapa_ruta_page.dart';
import '../../../resena/domain/entities/DestinoResenaEntity.dart';
import '../../../resena/presentation/pages/escribir_resena_page.dart';
import '../../../resena/presentation/providers/ResenasProvider.dart';
import '../../../resena/presentation/widgets/resena_card.dart';

class LugarDetailPage extends StatefulWidget {
  final String id;
  final String nombre;
  final String categoria;
  final double calificacion;
  final String imageUrl;
  final String? descripcion;
  final int totalResenas;
  final double? lat;
  final double? lng;

  const LugarDetailPage({
    super.key,
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.calificacion,
    required this.imageUrl,
    this.descripcion,
    this.totalResenas = 0,
    this.lat,
    this.lng,
  });

  @override
  State<LugarDetailPage> createState() => _LugarDetailPageState();
}

class _LugarDetailPageState extends State<LugarDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ResenasProvider>().cargarResenas(
            targetType: 'destination',
            targetId: widget.id,
          );
    });
  }

  void _irAEscribirResena() {
    final destino = DestinoResenaEntity(
      id: widget.id,
      nombre: widget.nombre,
      ubicacion: widget.categoria,
      imageUrl: widget.imageUrl,
      calificacion: widget.calificacion,
      totalResenas: widget.totalResenas,
      tipo: 'Naturaleza',
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EscribirResenaPage(destino: destino),
      ),
    );
  }

  bool get _tieneCoords => widget.lat != null && widget.lng != null;

  Future<void> _trazarRuta() async {
    if (!_tieneCoords) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapaRutaPage(
          nombre:  widget.nombre,
          destLat: widget.lat!,
          destLng: widget.lng!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: widget.imageUrl.isNotEmpty ? 260 : 0,
            pinned: true,
            backgroundColor: AppColors.surface(context),
            leading: IconButton(
              icon: Icon(Icons.arrow_back,
                  color: AppColors.textPrimary(context)),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              widget.nombre,
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            flexibleSpace: widget.imageUrl.isNotEmpty
                ? FlexibleSpaceBar(
                    background: Image.network(
                      widget.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.primaryContainer(context),
                      ),
                    ),
                  )
                : null,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Categoría y calificación ──────────────────────────────
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer(context),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.categoria,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary(context),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.star,
                          size: 16, color: Color(0xFFFFC107)),
                      const SizedBox(width: 4),
                      Text(
                        widget.calificacion.toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '  (${widget.totalResenas} reseñas)',
                        style: TextStyle(
                            color: AppColors.textSecondary(context),
                            fontSize: 13),
                      ),
                    ],
                  ),

                  // ── Descripción ───────────────────────────────────────────
                  if (widget.descripcion != null &&
                      widget.descripcion!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Acerca de este lugar',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.descripcion!,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary(context),
                        height: 1.6,
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // ── Sección reseñas ───────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Reseñas',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _irAEscribirResena,
                        icon: Icon(Icons.rate_review_outlined,
                            size: 18, color: AppColors.primary(context)),
                        label: Text(
                          'Escribir reseña',
                          style: TextStyle(color: AppColors.primary(context)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Consumer<ResenasProvider>(
                    builder: (context, provider, _) {
                      if (provider.status == ResenasStatus.loading) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      if (provider.resenas.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              'Aún no hay reseñas. ¡Sé el primero!',
                              style: TextStyle(
                                  color: AppColors.textSecondary(context)),
                            ),
                          ),
                        );
                      }
                      return Column(
                        children: provider.resenas
                            .map((r) => ResenaCard(resena: r))
                            .toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: _tieneCoords
              ? Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _trazarRuta,
                        icon: const Icon(Icons.directions_outlined,
                            color: Colors.white),
                        label: const Text(
                          'Trazar ruta',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1565C0),
                          elevation: 0,
                          minimumSize: const Size(0, 52),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _irAEscribirResena,
                        icon: const Icon(Icons.rate_review_outlined,
                            color: Colors.white),
                        label: const Text(
                          'Dejar reseña',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary(context),
                          elevation: 0,
                          minimumSize: const Size(0, 52),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
                    ),
                  ],
                )
              : ElevatedButton.icon(
                  onPressed: _irAEscribirResena,
                  icon: const Icon(Icons.rate_review_outlined,
                      color: Colors.white),
                  label: const Text(
                    'Dejar reseña',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary(context),
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                ),
        ),
      ),
    );
  }
}

// ── Bottom sheet de ruta ─────────────────────────────────────────────────────

class _RutaSheet extends StatefulWidget {
  final String nombre;
  final double destLat;
  final double destLng;

  const _RutaSheet({
    required this.nombre,
    required this.destLat,
    required this.destLng,
  });

  @override
  State<_RutaSheet> createState() => _RutaSheetState();
}

class _RutaSheetState extends State<_RutaSheet> {
  _RutaInfo? _info;
  String?    _error;
  bool       _cargando  = true;
  bool       _llegaste  = false;
  bool       _enVivo    = false;

  StreamSubscription<Position>? _posStream;
  Timer?    _osrmTimer;
  Position? _ultimaPos;

  @override
  void initState() {
    super.initState();
    _iniciar();
  }

  @override
  void dispose() {
    _posStream?.cancel();
    _osrmTimer?.cancel();
    super.dispose();
  }

  Future<void> _iniciar() async {
    final pos = await _obtenerPosicion();
    if (pos == null) {
      if (mounted) setState(() {
        _error = 'No se pudo obtener tu ubicación. Activa el GPS e intenta de nuevo.';
        _cargando = false;
      });
      return;
    }
    _ultimaPos = pos;
    await _calcularRuta(pos);
    _iniciarTracking();
  }

  // Calcula la ruta desde [pos] usando OSRM; fallback Haversine si falla.
  Future<void> _calcularRuta(Position pos) async {
    try {
      final resp = await Dio().get(
        'https://router.project-osrm.org/route/v1/driving/'
        '${pos.longitude},${pos.latitude};${widget.destLng},${widget.destLat}',
        queryParameters: {'overview': 'false'},
        options: Options(receiveTimeout: const Duration(seconds: 10)),
      );
      final routes = resp.data['routes'] as List?;
      if (routes != null && routes.isNotEmpty) {
        final route = routes[0] as Map;
        if (mounted) setState(() {
          _info = _RutaInfo(
            distanciaKm: (route['distance'] as num).toDouble() / 1000,
            duracionMin: (route['duration'] as num).toDouble() / 60,
            origenLat: pos.latitude,
            origenLng: pos.longitude,
          );
          _cargando = false;
        });
        return;
      }
    } catch (_) {}

    // Fallback Haversine con factor de carretera 1.4
    final dist = _haversine(pos.latitude, pos.longitude, widget.destLat, widget.destLng);
    if (mounted) setState(() {
      _info = _RutaInfo(
        distanciaKm: dist,
        duracionMin: dist * 1.4,
        origenLat: pos.latitude,
        origenLng: pos.longitude,
        esEstimado: true,
      );
      _cargando = false;
    });
  }

  void _iniciarTracking() {
    // Actualiza cada vez que el usuario se mueve ≥30 m
    _posStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 30,
      ),
    ).listen((pos) {
      _ultimaPos = pos;
      final dist = _haversine(pos.latitude, pos.longitude, widget.destLat, widget.destLng);

      if (dist < 0.1) {
        // Llegó (dentro de 100 m)
        if (mounted) setState(() => _llegaste = true);
        _posStream?.cancel();
        _osrmTimer?.cancel();
        return;
      }

      // Actualización rápida con Haversine mientras el usuario se mueve
      if (mounted) setState(() {
        _enVivo = true;
        _info = _RutaInfo(
          distanciaKm: dist,
          duracionMin: dist * 1.4,
          origenLat: pos.latitude,
          origenLng: pos.longitude,
          esEstimado: _info?.esEstimado ?? true,
        );
      });
    }, onError: (_) {});

    // Cada 2 minutos recalcula con OSRM para obtener distancia real por carretera
    _osrmTimer = Timer.periodic(const Duration(minutes: 2), (_) async {
      if (_ultimaPos != null && mounted) await _calcularRuta(_ultimaPos!);
    });
  }

  Future<Position?> _obtenerPosicion() async {
    try {
      final activo = await Geolocator.isLocationServiceEnabled();
      if (!activo) return null;
      var permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }
      if (permiso == LocationPermission.denied ||
          permiso == LocationPermission.deniedForever) return null;
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = _rad(lat2 - lat1);
    final dLon = _rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_rad(lat1)) * cos(_rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  double _rad(double deg) => deg * pi / 180;

  void _abrirEnMaps() {
    if (_info == null) return;
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&origin=${_info!.origenLat},${_info!.origenLng}'
      '&destination=${widget.destLat},${widget.destLng}'
      '&travelmode=driving',
    );
    launchUrl(url, mode: LaunchMode.externalApplication);
  }

  String _formatDuracion(double minutos) {
    final total = minutos.round();
    if (total < 60) return '$total min';
    final h = total ~/ 60;
    final m = total % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}min';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Título + badge EN VIVO
          Row(
            children: [
              const Icon(Icons.location_on, color: Color(0xFF1565C0), size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.nombre,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ),
              if (_enVivo && !_llegaste)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, color: Colors.white, size: 7),
                      SizedBox(width: 4),
                      Text('EN VIVO',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          if (_llegaste) ...[
            // ── Pantalla de llegada ───────────────────────────────────────
            const Icon(Icons.check_circle_outline,
                color: Colors.green, size: 56),
            const SizedBox(height: 10),
            Text(
              '¡Llegaste!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Estás en ${widget.nombre}',
              style: TextStyle(color: AppColors.textSecondary(context)),
            ),
          ] else if (_cargando) ...[
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            Text('Calculando ruta...',
                style: TextStyle(color: AppColors.textSecondary(context))),
          ] else if (_error != null) ...[
            Icon(Icons.error_outline, color: Colors.red[400], size: 40),
            const SizedBox(height: 8),
            Text(_error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary(context))),
          ] else if (_info != null) ...[
            // ── Métricas de ruta ──────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _InfoChip(
                  icon: Icons.access_time_outlined,
                  valor: _formatDuracion(_info!.duracionMin),
                  etiqueta: 'Tiempo restante',
                ),
                Container(width: 1, height: 50, color: Colors.grey[200]),
                _InfoChip(
                  icon: Icons.straighten_outlined,
                  valor: _info!.distanciaKm >= 1
                      ? '${_info!.distanciaKm.toStringAsFixed(1)} km'
                      : '${(_info!.distanciaKm * 1000).round()} m',
                  etiqueta: 'Distancia restante',
                ),
              ],
            ),
            if (_info!.esEstimado)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  _enVivo
                      ? '* Distancia en línea recta · se actualiza al moverte'
                      : '* Estimación en línea recta (sin conexión a servidor de rutas)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 11, color: AppColors.textSecondary(context)),
                ),
              ),
            if (!_enVivo && !_info!.esEstimado)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Se actualizará automáticamente al moverte',
                  style: TextStyle(
                      fontSize: 11, color: AppColors.textSecondary(context)),
                ),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _abrirEnMaps,
                icon: const Icon(Icons.open_in_new, color: Colors.white, size: 18),
                label: const Text(
                  'Abrir en Google Maps',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _RutaInfo {
  final double distanciaKm;
  final double duracionMin;
  final double origenLat;
  final double origenLng;
  final bool esEstimado;

  _RutaInfo({
    required this.distanciaKm,
    required this.duracionMin,
    required this.origenLat,
    required this.origenLng,
    this.esEstimado = false,
  });
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String valor;
  final String etiqueta;

  const _InfoChip({
    required this.icon,
    required this.valor,
    required this.etiqueta,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF1565C0), size: 28),
        const SizedBox(height: 6),
        Text(
          valor,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary(context),
          ),
        ),
        Text(
          etiqueta,
          style: TextStyle(
              fontSize: 12, color: AppColors.textSecondary(context)),
        ),
      ],
    );
  }
}
