import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/network/ml_api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import 'lugar_detail_page.dart';

/// Un lugar recomendado por el motor de Machine Learning (`GET
/// /destacados`), pensado para recorrerse caminando. Estos lugares no
/// vienen de una fila real del backend (no tienen UUID ni categoryId),
/// así que se muestran con la misma etiqueta "recomendación" que ya usa
/// el resto de la app para datos del ML — nunca se presentan como si
/// fueran destinos verificados por ExploraChiapas.
class _LugarRecomendado {
  final String id;
  final String nombre;
  final String municipio;
  final String categoria;
  final String? imageUrl;
  final double calificacion;
  final double lat;
  final double lng;
  final double? distanciaKm;

  const _LugarRecomendado({
    required this.id,
    required this.nombre,
    required this.municipio,
    required this.categoria,
    required this.imageUrl,
    required this.calificacion,
    required this.lat,
    required this.lng,
    this.distanciaKm,
  });
}

class RutasUrbanasPage extends StatefulWidget {
  const RutasUrbanasPage({super.key});

  @override
  State<RutasUrbanasPage> createState() => _RutasUrbanasPageState();
}

enum _CargaEstado { cargando, listo, vacio }

class _RutasUrbanasPageState extends State<RutasUrbanasPage> {
  final _mapCtrl = MapController();

  _CargaEstado _estado = _CargaEstado.cargando;
  List<_LugarRecomendado> _lugares = [];
  Position? _posicionUsuario;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargar());
  }

  Future<void> _cargar() async {
    // La posición del usuario es opcional (solo para ordenar por
    // cercanía y centrar el mapa): si el GPS no está disponible o el
    // permiso se niega, se sigue mostrando la lista igual, sin bloquear.
    final posicion = await _obtenerPosicionSilenciosa();
    if (mounted) setState(() => _posicionUsuario = posicion);

    final destacados = await getIt<MlApiClient>().fetchDestacados(limite: 15);

    final lugares = destacados
        .map((d) => _mapear(d, posicion))
        .whereType<_LugarRecomendado>()
        .toList();

    if (posicion != null) {
      lugares.sort(
        (a, b) => (a.distanciaKm ?? 0).compareTo(b.distanciaKm ?? 0),
      );
    }

    if (!mounted) return;
    setState(() {
      _lugares = lugares;
      _estado = lugares.isEmpty ? _CargaEstado.vacio : _CargaEstado.listo;
    });
    _ajustarCamara();
  }

  _LugarRecomendado? _mapear(Map<String, dynamic> d, Position? posicion) {
    final lat = (d['lat'] as num?)?.toDouble();
    final lng = (d['lng'] as num?)?.toDouble();
    if (lat == null || lng == null) return null;

    return _LugarRecomendado(
      id: d['id']?.toString() ?? '',
      nombre: d['nombre'] as String? ?? 'Lugar sin nombre',
      municipio: d['municipio'] as String? ?? '',
      categoria: d['categoria'] as String? ?? 'general',
      imageUrl: d['foto_principal'] as String?,
      calificacion: (d['calificacion'] as num?)?.toDouble() ?? 0,
      lat: lat,
      lng: lng,
      distanciaKm: posicion != null
          ? _haversine(posicion.latitude, posicion.longitude, lat, lng)
          : null,
    );
  }

  Future<Position?> _obtenerPosicionSilenciosa() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      var permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }
      if (permiso == LocationPermission.denied ||
          permiso == LocationPermission.deniedForever) {
        return null;
      }
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 8),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  void _ajustarCamara() {
    final puntos = [
      if (_posicionUsuario != null)
        LatLng(_posicionUsuario!.latitude, _posicionUsuario!.longitude),
      for (final l in _lugares) LatLng(l.lat, l.lng),
    ];
    if (puntos.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (puntos.length == 1) {
        _mapCtrl.move(puntos.first, 13);
        return;
      }
      _mapCtrl.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(puntos),
          padding: const EdgeInsets.all(44),
        ),
      );
    });
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

  double _rad(double deg) => deg * pi / 180;

  void _abrirLugar(_LugarRecomendado lugar) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LugarDetailPage(
          id: lugar.id,
          nombre: lugar.nombre,
          categoria: lugar.categoria,
          calificacion: lugar.calificacion,
          imageUrl: lugar.imageUrl ?? '',
          lat: lugar.lat,
          lng: lugar.lng,
          // Recomendación del motor ML, no una fila real del backend:
          // no tiene UUID ni categoryId reales, así que no puede
          // recibir reseñas todavía.
          targetType: null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.surface(context),
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary(context)),
        title: Text(
          'Rutas Urbanas',
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 220, child: _buildMapa(context)),
          Expanded(child: _buildContenido(context)),
        ],
      ),
    );
  }

  Widget _buildMapa(BuildContext context) {
    final userPt = _posicionUsuario != null
        ? LatLng(_posicionUsuario!.latitude, _posicionUsuario!.longitude)
        : null;

    return FlutterMap(
      mapController: _mapCtrl,
      options: MapOptions(
        initialCenter: userPt ?? const LatLng(16.75, -93.11),
        initialZoom: userPt != null ? 12 : 7,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.explorachiapas.app',
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
                    shape: BoxShape.circle,
                    color: const Color(0xFF2196F3),
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: const [
                      BoxShadow(color: Colors.black38, blurRadius: 6),
                    ],
                  ),
                ),
              ),
            for (final lugar in _lugares)
              Marker(
                point: LatLng(lugar.lat, lugar.lng),
                width: 36,
                height: 36,
                alignment: Alignment.topCenter,
                child: GestureDetector(
                  onTap: () => _abrirLugar(lugar),
                  child: Icon(
                    Icons.directions_walk,
                    color: AppColors.primary(context),
                    size: 34,
                    shadows: const [
                      Shadow(color: Colors.black38, blurRadius: 4),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildContenido(BuildContext context) {
    switch (_estado) {
      case _CargaEstado.cargando:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 14),
              Text(
                'Buscando rutas urbanas cercanas...',
                style: TextStyle(color: AppColors.textSecondary(context)),
              ),
            ],
          ),
        );

      case _CargaEstado.vacio:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.directions_walk_outlined,
                  size: 40,
                  color: AppColors.textSecondary(context),
                ),
                const SizedBox(height: 12),
                Text(
                  'Sin sugerencias por ahora',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'No pudimos obtener recomendaciones del motor de rutas '
                  'en este momento. Intenta de nuevo más tarde.',
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

      case _CargaEstado.listo:
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: _lugares.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            if (index == 0) {
              return const _EtiquetaRecomendacionML();
            }
            final lugar = _lugares[index - 1];
            return FadeSlideIn(
              delay: Duration(milliseconds: 40 * index),
              child: _LugarRecomendadoCard(
                lugar: lugar,
                onTap: () => _abrirLugar(lugar),
              ),
            );
          },
        );
    }
  }
}

class _EtiquetaRecomendacionML extends StatelessWidget {
  const _EtiquetaRecomendacionML();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            Icons.auto_awesome_outlined,
            size: 14,
            color: AppColors.textSecondary(context),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Sugerencias del motor de recomendación, ideales para '
              'recorrer a pie',
              style: TextStyle(
                fontSize: 11.5,
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LugarRecomendadoCard extends StatefulWidget {
  final _LugarRecomendado lugar;
  final VoidCallback onTap;

  const _LugarRecomendadoCard({required this.lugar, required this.onTap});

  @override
  State<_LugarRecomendadoCard> createState() => _LugarRecomendadoCardState();
}

class _LugarRecomendadoCardState extends State<_LugarRecomendadoCard> {
  bool _presionado = false;

  @override
  Widget build(BuildContext context) {
    final lugar = widget.lugar;
    return Listener(
      onPointerDown: (_) => setState(() => _presionado = true),
      onPointerUp: (_) => setState(() => _presionado = false),
      onPointerCancel: (_) => setState(() => _presionado = false),
      child: AnimatedScale(
        scale: _presionado ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: widget.onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderSubtle(context)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: lugar.imageUrl != null && lugar.imageUrl!.isNotEmpty
                      ? Image.network(
                          lugar.imageUrl!,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholder(context),
                        )
                      : _placeholder(context),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lugar.nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              lugar.municipio.isNotEmpty
                                  ? lugar.municipio
                                  : lugar.categoria,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: AppColors.textSecondary(context),
                              ),
                            ),
                          ),
                          if (lugar.distanciaKm != null) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.near_me_outlined,
                              size: 13,
                              color: AppColors.textSecondary(context),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              lugar.distanciaKm! < 1
                                  ? '${(lugar.distanciaKm! * 1000).round()} m'
                                  : '${lugar.distanciaKm!.toStringAsFixed(1)} km',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: AppColors.textSecondary(context),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _placeholder(BuildContext context) => Container(
    width: 56,
    height: 56,
    color: AppColors.primaryContainer(context),
    child: Icon(
      Icons.directions_walk,
      color: AppColors.primary(context),
      size: 24,
    ),
  );
}
