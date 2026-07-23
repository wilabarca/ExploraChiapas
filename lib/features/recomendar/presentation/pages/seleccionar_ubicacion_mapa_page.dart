import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/services/location_service.dart';
import '../../../../core/services/reverse_geocoding_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/ubicacion_seleccionada.dart';

/// Centro de mapa usado únicamente como punto de partida visual cuando
/// todavía no se conoce ninguna posición real (ni GPS ni una ya elegida
/// antes). Nunca se usa como la ubicación que se envía al backend: el
/// usuario siempre debe mover el mapa y confirmar antes de continuar.
const _centroInicialChiapas = LatLng(16.7531, -93.1156); // Tuxtla Gutiérrez

/// Selector de ubicación en mapa: el pin permanece fijo en el centro de
/// la pantalla y es el mapa el que se desplaza debajo — el mismo patrón
/// que usan Google Maps/Uber para elegir una dirección con precisión.
/// Al confirmar, devuelve el `LatLng` real bajo el pin (`Navigator.pop`).
class SeleccionarUbicacionMapaPage extends StatefulWidget {
  final double? latitudInicial;
  final double? longitudInicial;

  const SeleccionarUbicacionMapaPage({
    super.key,
    this.latitudInicial,
    this.longitudInicial,
  });

  @override
  State<SeleccionarUbicacionMapaPage> createState() =>
      _SeleccionarUbicacionMapaPageState();
}

class _SeleccionarUbicacionMapaPageState
    extends State<SeleccionarUbicacionMapaPage> {
  final _mapCtrl = MapController();

  late LatLng _centro;
  bool _moviendoMapa = false;
  bool _buscandoMiUbicacion = false;
  bool _confirmando = false;
  String? _errorUbicacion;

  @override
  void initState() {
    super.initState();
    _centro = (widget.latitudInicial != null && widget.longitudInicial != null)
        ? LatLng(widget.latitudInicial!, widget.longitudInicial!)
        : _centroInicialChiapas;
  }

  @override
  void dispose() {
    _mapCtrl.dispose();
    super.dispose();
  }

  Future<void> _usarMiUbicacionActual() async {
    setState(() {
      _buscandoMiUbicacion = true;
      _errorUbicacion = null;
    });

    final posicion = await LocationService().getCurrentPosition();

    if (!mounted) return;
    setState(() => _buscandoMiUbicacion = false);

    if (posicion == null) {
      setState(
        () => _errorUbicacion =
            'No pudimos obtener tu ubicación actual. Verifica que el GPS '
            'esté activado o mueve el mapa manualmente.',
      );
      return;
    }

    final destino = LatLng(posicion.latitude, posicion.longitude);
    setState(() => _centro = destino);
    _mapCtrl.move(destino, 16);
  }

  Future<void> _confirmar() async {
    if (_confirmando) return;
    setState(() => _confirmando = true);

    // Geocodificación inversa real (Nominatim/OpenStreetMap, el mismo
    // proyecto que ya provee los tiles del mapa) para obtener
    // dirección/municipio/estado reales del punto elegido. Si falla o no
    // hay datos, se envía únicamente lat/lng — nunca un valor inventado.
    final direccion = await ReverseGeocodingService().buscar(
      latitude: _centro.latitude,
      longitude: _centro.longitude,
    );

    if (!mounted) return;
    setState(() => _confirmando = false);

    Navigator.pop(
      context,
      UbicacionSeleccionada(
        latitude: _centro.latitude,
        longitude: _centro.longitude,
        address: direccion?.address,
        municipality: direccion?.municipality,
        state: direccion?.state,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapCtrl,
            options: MapOptions(
              initialCenter: _centro,
              initialZoom: 15,
              onPositionChanged: (camera, hasGesture) {
                _centro = camera.center;
                if (hasGesture && !_moviendoMapa) {
                  setState(() => _moviendoMapa = true);
                } else if (!hasGesture && _moviendoMapa) {
                  setState(() => _moviendoMapa = false);
                }
              },
              onMapEvent: (event) {
                if (event is MapEventMoveEnd) {
                  setState(() => _moviendoMapa = false);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.explorachiapas.app',
              ),
            ],
          ),

          // ── Pin fijo en el centro de la pantalla ─────────────────────
          IgnorePointer(
            child: Center(
              child: Padding(
                // Compensa que el ancla del pin es su punta, no su centro.
                padding: const EdgeInsets.only(bottom: 36),
                child: AnimatedScale(
                  scale: _moviendoMapa ? 1.15 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOut,
                  child: AnimatedSlide(
                    offset: _moviendoMapa
                        ? const Offset(0, -0.08)
                        : Offset.zero,
                    duration: const Duration(milliseconds: 150),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_pin,
                          color: AppColors.primary(context),
                          size: 46,
                          shadows: const [
                            Shadow(color: Colors.black38, blurRadius: 6),
                          ],
                        ),
                        // Sombra en el suelo: refuerza la sensación de
                        // "el pin flota sobre este punto exacto".
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: _moviendoMapa ? 10 : 14,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Barra superior ────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                8,
                MediaQuery.of(context).padding.top + 4,
                16,
                12,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.45),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Ajusta el pin en la ubicación exacta',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Botón "mi ubicación" flotante ─────────────────────────────
          Positioned(
            right: 16,
            bottom: 190,
            child: FloatingActionButton.small(
              heroTag: 'usar-mi-ubicacion',
              backgroundColor: AppColors.surface(context),
              onPressed: _buscandoMiUbicacion ? null : _usarMiUbicacionActual,
              child: _buscandoMiUbicacion
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary(context),
                      ),
                    )
                  : Icon(Icons.my_location, color: AppColors.primary(context)),
            ),
          ),

          // ── Panel inferior ────────────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                MediaQuery.of(context).padding.bottom + 20,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 12,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_errorUbicacion != null) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 16,
                          color: AppColors.error(context),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _errorUbicacion!,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: AppColors.error(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    children: [
                      Icon(
                        Icons.pin_drop_outlined,
                        size: 18,
                        color: AppColors.primary(context),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${_centro.latitude.toStringAsFixed(5)}, '
                          '${_centro.longitude.toStringAsFixed(5)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _confirmando ? null : _confirmar,
                      icon: _confirmando
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check, color: Colors.white),
                      label: Text(
                        _confirmando
                            ? 'Ubicando dirección...'
                            : 'Confirmar esta ubicación',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary(context),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
