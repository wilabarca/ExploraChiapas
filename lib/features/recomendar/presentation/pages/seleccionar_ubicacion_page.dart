import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/ubicacion_propuesta.dart';

class SeleccionarUbicacionPage extends StatefulWidget {
  final UbicacionPropuesta? ubicacionInicial;

  const SeleccionarUbicacionPage({super.key, this.ubicacionInicial});

  @override
  State<SeleccionarUbicacionPage> createState() => _SeleccionarUbicacionPageState();
}

class _SeleccionarUbicacionPageState extends State<SeleccionarUbicacionPage> {
  // Centro inicial: Chiapas
  static const _centroChiapas = LatLng(16.7521, -93.1152);

  LatLng? _puntoSeleccionado;
  String _direccion = '';
  String _municipio = '';
  bool _buscandoDireccion = false;

  final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
  ));

  @override
  void initState() {
    super.initState();
    final inicial = widget.ubicacionInicial;
    if (inicial != null) {
      _puntoSeleccionado = LatLng(inicial.latitude, inicial.longitude);
      _direccion = inicial.address;
      _municipio = inicial.municipality;
    }
  }

  Future<void> _geocodificarInverso(LatLng punto) async {
    setState(() => _buscandoDireccion = true);
    try {
      final resp = await _dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'lat': punto.latitude,
          'lon': punto.longitude,
          'format': 'json',
          'accept-language': 'es',
        },
        options: Options(headers: {
          'User-Agent': 'ExploraChiapas/1.0 (educational project)',
        }),
      );

      final data = resp.data is String
          ? jsonDecode(resp.data as String)
          : resp.data as Map<String, dynamic>;

      final address = data['address'] as Map<String, dynamic>? ?? {};

      final partesDireccion = <String>[
        if (address['road'] != null) address['road'].toString(),
        if (address['suburb'] != null) address['suburb'].toString(),
      ];

      final municipioRaw = address['municipality']?.toString() ??
          address['city']?.toString() ??
          address['town']?.toString() ??
          address['village']?.toString() ??
          address['county']?.toString() ??
          '';

      setState(() {
        _municipio = municipioRaw;
        _direccion = partesDireccion.isNotEmpty
            ? partesDireccion.join(', ')
            : data['display_name']?.toString() ?? 'Chiapas, México';
      });
    } catch (_) {
      setState(() {
        _direccion = 'Chiapas, México';
        _municipio = 'Chiapas';
      });
    } finally {
      setState(() => _buscandoDireccion = false);
    }
  }

  void _confirmar() {
    if (_puntoSeleccionado == null) return;
    final resultado = UbicacionPropuesta(
      latitude: _puntoSeleccionado!.latitude,
      longitude: _puntoSeleccionado!.longitude,
      address: _direccion.isEmpty ? 'Chiapas, México' : _direccion,
      municipality: _municipio.isEmpty ? 'Chiapas' : _municipio,
      state: 'Chiapas',
      mapProvider: 'openstreetmap',
    );
    Navigator.pop(context, resultado);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tieneSeleccion = _puntoSeleccionado != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar ubicación'),
        actions: [
          if (tieneSeleccion)
            TextButton(
              onPressed: _buscandoDireccion ? null : _confirmar,
              child: Text(
                'Confirmar',
                style: TextStyle(
                  color: cs.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: cs.primaryContainer,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Icon(Icons.touch_app_outlined, size: 18, color: cs.onPrimaryContainer),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Toca el mapa para colocar el marcador en el lugar',
                    style: TextStyle(
                      fontSize: 13,
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: _puntoSeleccionado ?? _centroChiapas,
                initialZoom: _puntoSeleccionado != null ? 14.0 : 9.0,
                onTap: (_, latLng) {
                  setState(() => _puntoSeleccionado = latLng);
                  _geocodificarInverso(latLng);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.explorachiapas.app',
                ),
                if (tieneSeleccion)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _puntoSeleccionado!,
                        width: 48,
                        height: 48,
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 48,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          if (tieneSeleccion)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, color: cs.primary, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Ubicación seleccionada',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                      ),
                      const Spacer(),
                      if (_buscandoDireccion)
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: cs.primary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (_municipio.isNotEmpty)
                    Text(
                      _municipio.isNotEmpty ? '$_municipio, Chiapas' : 'Chiapas',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: cs.onSurface,
                      ),
                    ),
                  if (_direccion.isNotEmpty && _direccion != 'Chiapas, México')
                    Text(
                      _direccion,
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurface.withValues(alpha: 0.6),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  Text(
                    '${_puntoSeleccionado!.latitude.toStringAsFixed(6)}, '
                    '${_puntoSeleccionado!.longitude.toStringAsFixed(6)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: cs.onSurface.withValues(alpha: 0.45),
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _buscandoDireccion ? null : _confirmar,
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Confirmar ubicación'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
