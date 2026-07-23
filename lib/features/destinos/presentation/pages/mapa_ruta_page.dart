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

  // Ángulo acumulado (sin envolver a 0-360) para que la flecha de
  // dirección gire siempre por el camino más corto, sin dar una vuelta
  // completa falsa cada vez que el rumbo cruza el norte (359° → 1°).
  double _headingAcumulado = 0;
  bool _enMovimiento = false;

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
          // 8 m (en vez de 30) para que el punto y la flecha del usuario
          // se sientan continuos caminando, no solo en auto.
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 8,
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

          // El GPS solo reporta un rumbo confiable cuando el usuario se
          // está desplazando; parado, `heading` oscila sin sentido.
          final moviendose = pos.speed > 0.3;
          if (moviendose && pos.heading >= 0) {
            _actualizarHeadingAcumulado(pos.heading);
          }

          setState(() {
            _enVivo = true;
            _enMovimiento = moviendose;
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

  /// Suma el giro más corto hacia [nuevoHeading] al ángulo acumulado, en
  /// vez de asignarlo directamente — así `AnimatedRotation` nunca da una
  /// vuelta completa de más al cruzar el norte (359° → 1°).
  void _actualizarHeadingAcumulado(double nuevoHeading) {
    final diferencia = ((nuevoHeading - _headingAcumulado + 540) % 360) - 180;
    _headingAcumulado += diferencia;
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
    final userPt = _pos != null
        ? LatLng(_pos!.latitude, _pos!.longitude)
        : null;
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
                      width: 64,
                      height: 64,
                      child: _UserLocationMarker(
                        color: AppColors.primary(context),
                        headingAcumulado: _headingAcumulado,
                        enMovimiento: _enMovimiento,
                      ),
                    ),
                  Marker(
                    point: destPt,
                    width: 42,
                    height: 42,
                    alignment: Alignment.topCenter,
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 42,
                    ),
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
                    icon: Icon(
                      Icons.arrow_back,
                      color: AppColors.onPrimary(context),
                    ),
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
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, -3),
                  ),
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
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
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
      const Text(
        '¡Llegaste!',
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 4),
      Text(
        'Estás en ${widget.nombre}',
        style: const TextStyle(color: Colors.grey),
      ),
    ],
  );

  Widget _panelRuta() => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      // Modo de ruta — siempre en carro (ruta calculada con OSRM driving).
      AnimatedOpacity(
        opacity: 1,
        duration: const Duration(milliseconds: 300),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer(context),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.directions_car_filled,
                size: 14,
                color: AppColors.primary(context),
              ),
              const SizedBox(width: 5),
              Text(
                'Ruta en carro',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary(context),
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 12),
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

/// Marcador de "mi ubicación": siempre una flecha de dirección (nunca un
/// punto), con anillo pulsante detrás que solo late mientras el usuario
/// se mueve — para reforzar visualmente que la posición se sigue
/// actualizando en vivo justo cuando el carro avanza. Gira suave hacia
/// el rumbo real y da un pequeño "pop" cada vez que llega una posición
/// nueva, para que cada actualización se sienta viva.
class _UserLocationMarker extends StatefulWidget {
  final Color color;
  final double headingAcumulado;
  final bool enMovimiento;

  const _UserLocationMarker({
    required this.color,
    required this.headingAcumulado,
    required this.enMovimiento,
  });

  @override
  State<_UserLocationMarker> createState() => _UserLocationMarkerState();
}

class _UserLocationMarkerState extends State<_UserLocationMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _popCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );
  late final Animation<double> _pop = Tween<double>(
    begin: 1,
    end: 1.16,
  ).chain(CurveTween(curve: Curves.easeOut)).animate(_popCtrl);

  @override
  void didUpdateWidget(covariant _UserLocationMarker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.headingAcumulado != widget.headingAcumulado) {
      _popCtrl.forward(from: 0).then((_) => _popCtrl.reverse());
    }
  }

  @override
  void dispose() {
    _popCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        _PulsingRing(color: widget.color, activo: widget.enMovimiento),
        AnimatedRotation(
          turns: widget.headingAcumulado / 360,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: AnimatedBuilder(
            animation: _pop,
            builder: (context, child) =>
                Transform.scale(scale: _pop.value, child: child),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Icon(
                Icons.navigation,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Anillo translúcido que crece y se desvanece en bucle, alrededor del
/// punto de "mi ubicación" — la misma idea visual que Google/Apple Maps
/// usan para indicar "esto se está actualizando en tiempo real".
class _PulsingRing extends StatefulWidget {
  final Color color;

  /// Solo late mientras el usuario se mueve; parado se queda como un
  /// anillo tenue y fijo, en vez de seguir animando sin sentido.
  final bool activo;

  const _PulsingRing({required this.color, required this.activo});

  @override
  State<_PulsingRing> createState() => _PulsingRingState();
}

class _PulsingRingState extends State<_PulsingRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  );

  @override
  void initState() {
    super.initState();
    if (widget.activo) _ctrl.repeat();
  }

  @override
  void didUpdateWidget(covariant _PulsingRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activo && !_ctrl.isAnimating) {
      _ctrl.repeat();
    } else if (!widget.activo && _ctrl.isAnimating) {
      _ctrl.animateTo(0, duration: const Duration(milliseconds: 300));
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = _ctrl.value;
        return Container(
          width: 20 + 34 * t,
          height: 20 + 34 * t,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withValues(alpha: (1 - t) * 0.30),
          ),
        );
      },
    );
  }
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
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: ScaleTransition(scale: animation, child: child),
          ),
          child: Text(
            valor,
            key: ValueKey(valor),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        Text(
          etiqueta,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }
}
