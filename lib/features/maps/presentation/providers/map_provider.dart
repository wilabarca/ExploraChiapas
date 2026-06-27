import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../domain/entities/destination_entity.dart';
import '../../domain/usecases/get_destinations_usecase.dart';
import '../../domain/usecases/get_routes_usecase.dart';

enum MapStatus { idle, loading, loaded, error }

class MapProvider extends ChangeNotifier {
  final GetDestinationsUseCase _getDestinations;
  final GetRouteUseCase _getRoute;

  MapProvider(this._getDestinations, this._getRoute);

  MapStatus _status = MapStatus.idle;
  MapStatus get status => _status;

  List<DestinationEntity> _destinations = [];
  List<DestinationEntity> get destinations => _destinations;

  Set<Marker> _markers = {};
  Set<Marker> get markers => _markers;

  Set<Polyline> _polylines = {};
  Set<Polyline> get polylines => _polylines;

  DestinationEntity? _selected;
  DestinationEntity? get selected => _selected;

  String? _filtroTipo;

  static const _colores = {
    'naturaleza': Color(0xFF2E7D32),
    'cultura':    Color(0xFF1565C0),
    'gastronomia': Color(0xFFE65100),
    'aventura':   Color(0xFF6A1B9A),
    'descanso':   Color(0xFF00838F),
  };

  Future<void> loadDestinations({String? tipo}) async {
    _filtroTipo = tipo;
    _status = MapStatus.loading;
    _polylines = {};
    _selected = null;
    notifyListeners();

    try {
      _destinations = await _getDestinations(tipo: tipo);
      _buildMarkers();
      _status = MapStatus.loaded;
    } catch (_) {
      _status = MapStatus.error;
    }
    notifyListeners();
  }

  void _buildMarkers() {
    _markers = _destinations.map((d) {
      return Marker(
        markerId: MarkerId(d.id),
        position: LatLng(d.lat, d.lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          _markerHue(d.tipo),
        ),
        infoWindow: InfoWindow(title: d.nombre, snippet: d.tipo),
        onTap: () => selectDestination(d),
      );
    }).toSet();
  }

  double _markerHue(String tipo) {
    switch (tipo) {
      case 'naturaleza':  return BitmapDescriptor.hueGreen;
      case 'cultura':     return BitmapDescriptor.hueBlue;
      case 'gastronomia': return BitmapDescriptor.hueOrange;
      case 'aventura':    return BitmapDescriptor.hueViolet;
      default:            return BitmapDescriptor.hueCyan;
    }
  }

  void selectDestination(DestinationEntity destino) {
    _selected = destino;
    notifyListeners();
  }

  void clearSelection() {
    _selected = null;
    _polylines = {};
    notifyListeners();
  }

  Future<void> loadRouteTo(DestinationEntity destino) async {
    // Origen ficticio: centro de Tuxtla Gutiérrez
    const originLat = 16.7521;
    const originLng = -93.1152;

    try {
      final puntos = await _getRoute(
        originLat: originLat,
        originLng: originLng,
        destLat: destino.lat,
        destLng: destino.lng,
      );

      _polylines = {
        Polyline(
          polylineId: const PolylineId('ruta_principal'),
          points: puntos.map((p) => LatLng(p[0], p[1])).toList(),
          color: const Color(0xFF2E7D32),
          width: 4,
        ),
      };
      notifyListeners();
    } catch (_) {
      // silencia error de ruta, no bloquea el flujo
    }
  }
}