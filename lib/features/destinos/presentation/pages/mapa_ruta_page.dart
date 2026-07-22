import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

class MapaRutaPage extends StatefulWidget {
  final String nombre;
  final double destLat;
  final double destLng;

  const MapaRutaPage({
    super.key,
    required this.nombre,
    required this.destLat,
    required this.destLng,
  });

  @override
  State<MapaRutaPage> createState() => _MapaRutaPageState();
}

class _MapaRutaPageState extends State<MapaRutaPage> {
  final _mapCtrl = MapController();

  Position? _pos;
  List<LatLng> _ruta = [];
  double _distKm = 0;
  double _durMin = 0;
  bool _cargando = true;
  bool _llegaste = false;
  bool _esEstimado = false;
  bool _enVivo = false;

  StreamSubscription<Position>? _stream;
  Timer? _osrmTimer;

  @override
  void initState() {
    super.initState();
    _iniciar();
  }

  @override
  void dispose() {
    _stream?.cancel();
    _osrmTimer?.cancel();
    _mapCtrl.dispose();
    super.dispose();
  }

  Future<void> _iniciar() async {
    final pos = await _obtenerPos();
    if (pos == null) {
      if (mounted) setState(() => _cargando = false);
      return;
    }
    _pos = pos;
    await _calcularOSRM(pos);
    _iniciarTracking();
  }

  Future<void> _calcularOSRM(Position pos) async {
    try {
      final resp = await Dio().get(
        'https://router.project-osrm.org/route/v1/driving/'
        '${pos.longitude},${pos.latitude};${widget.destLng},${widget.destLat}',
        queryParameters: {'overview': 'full', 'geometries': 'geojson'},
        options: Options(receiveTimeout: const Duration(seconds: 12)),
      );
      final routes = resp.data['routes'] as List?;
      if (routes != null && routes.isNotEmpty) {
        final route = routes[0] as Map;
        final coords = (route['geometry']['coordinates'] as List)
            .map(
              (c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()),
            )
            .toList();
        if (mounted) {
          setState(() {
            _ruta = coords;
            _distKm = (route['distance'] as num).toDouble() / 1000;
            _durMin = (route['duration'] as num).toDouble() / 60;
            _cargando = false;
            _esEstimado = false;
          });
          _ajustarCamara();
        }
        return;
      }
    } catch (_) {}

    // Fallback línea recta
    final dist = _haversine(
      pos.latitude,
      pos.longitude,
      widget.destLat,
      widget.destLng,
    );
    if (mounted) {
      setState(() {
        _ruta = [
          LatLng(pos.latitude, pos.longitude),
          LatLng(widget.destLat, widget.destLng),
        ];
        _distKm = dist;
        _durMin = dist * 1.4;
        _cargando = false;
        _esEstimado = true;
      });
      _ajustarCamara();
    }
  }

  void _ajustarCamara() {
    if (_ruta.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _ruta.isEmpty) return;
      _mapCtrl.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(_ruta),
          padding: const EdgeInsets.fromLTRB(48, 120, 48, 220),
        ),
      );
    });
  }

  void _iniciarTracking() {
    _stream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 30,
          ),
        ).listen((pos) {
          if (!mounted) return;
          _pos = pos;
          final dist = _haversine(
            pos.latitude,
            pos.longitude,
            widget.destLat,
            widget.destLng,
          );

      if (dist < 0.1) {
        setState(() => _llegaste = true);
        _stream?.cancel();
        _osrmTimer?.cancel();
        return;
      }

          setState(() {
            _enVivo = true;
            _distKm = dist;
            _durMin = dist * 1.4;
            // Actualizar primer punto de la ruta con posición actual
            if (_ruta.isNotEmpty) {
              _ruta = [LatLng(pos.latitude, pos.longitude), ..._ruta.skip(1)];
            }
          });

          _mapCtrl.move(
            LatLng(pos.latitude, pos.longitude),
            _mapCtrl.camera.zoom,
          );
        }, onError: (_) {});

    _osrmTimer = Timer.periodic(const Duration(minutes: 2), (_) async {
      if (_pos != null && mounted) await _calcularOSRM(_pos!);
    });
  }

  Future<Position?> _obtenerPos() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      var p = await Geolocator.checkPermission();
      if (p == LocationPermission.denied)
        p = await Geolocator.requestPermission();
      if (p == LocationPermission.denied ||
          p == LocationPermission.deniedForever)
        return null;
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
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_rad(lat1)) * cos(_rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  double _rad(double d) => d * pi / 180;

  String _fmtDist(double km) =>
      km < 1 ? '${(km * 1000).round()} m' : '${km.toStringAsFixed(1)} km';

  String _fmtTiempo(double min) {
    final t = min.round();
    if (t < 60) return '$t min';
    final h = t ~/ 60;
    final m = t % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Theme(
      data: isDark ? AppTheme.dark() : AppTheme.light(),
      child: Builder(builder: (context) => _buildContent(context)),
    );
  }

  Widget _buildContent(BuildContext context) {
    final userPt = _pos != null ? LatLng(_pos!.latitude, _pos!.longitude) : null;
    final destPt = LatLng(widget.destLat, widget.destLng);

    return Scaffold(
      body: Stack(
        children: [
          // ── Mapa ───────────────────────────────────────────────────────
          FlutterMap(
            mapController: _mapCtrl,
            options: MapOptions(
              initialCenter: userPt ?? destPt,
              initialZoom: 13,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.explorachiapas.app',
              ),
              if (_ruta.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _ruta,
                      color: AppColors.primary(context),
                      strokeWidth: 6,
                      borderColor: Colors.white,
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  if (userPt != null)
                    Marker(
                      point: userPt,
                      width: 22,
                      height: 22,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary(context),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 6),
                          ],
                        ),
                      ),
                    ),
                  Marker(
                    point: destPt,
                    width: 42,
                    height: 42,
                    alignment: Alignment.topCenter,
                    child: const Icon(Icons.location_pin, color: Colors.red, size: 42),
                  ),
                ],
              ),
            ],
          ),

          // ── Barra superior ──────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: AppColors.primary(context),
              padding: EdgeInsets.fromLTRB(
                16,
                MediaQuery.of(context).padding.top + 8,
                16,
                12,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: AppColors.onPrimary(context)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      widget.nombre,
                      style: TextStyle(
                        color: AppColors.onPrimary(context),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (_enVivo && !_llegaste)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, color: Colors.white, size: 7),
                          SizedBox(width: 4),
                          Text(
                            'EN VIVO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Panel inferior ──────────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -3))
                ],
              ),
              padding: EdgeInsets.fromLTRB(
                24,
                16,
                24,
                MediaQuery.of(context).padding.bottom + 20,
              ),
              child: _llegaste
                  ? _panelLlegaste()
                  : _cargando
                  ? _panelCargando()
                  : _panelRuta(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _panelCargando() => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 12),
            Text('Calculando ruta...'),
          ],
        ),
      );

  Widget _panelLlegaste() => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.green, size: 48),
          const SizedBox(height: 8),
          const Text('¡Llegaste!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Estás en ${widget.nombre}',
              style: const TextStyle(color: Colors.grey)),
        ],
      );

  Widget _panelRuta() => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Métricas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _Metrica(
                icono: Icons.access_time_outlined,
                valor: _fmtTiempo(_durMin),
                etiqueta: 'Tiempo restante',
              ),
              Container(width: 1, height: 48, color: Colors.grey[200]),
              _Metrica(
                icono: Icons.straighten_outlined,
                valor: _fmtDist(_distKm),
                etiqueta: 'Distancia restante',
              ),
            ],
          ),
          if (_esEstimado) ...[
            const SizedBox(height: 6),
            const Text(
              '* Línea recta — sin conexión al servidor de rutas',
              style: TextStyle(fontSize: 11, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      );
}

class _Metrica extends StatelessWidget {
  final IconData icono;
  final String valor;
  final String etiqueta;

  const _Metrica({
    required this.icono,
    required this.valor,
    required this.etiqueta,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icono, color: AppColors.primary(context), size: 26),
        const SizedBox(height: 4),
        Text(valor,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Text(etiqueta,
            style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
