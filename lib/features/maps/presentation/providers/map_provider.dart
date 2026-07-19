import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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

  List<List<double>> _routePoints = [];
  List<List<double>> get routePoints => _routePoints;

  DestinationEntity? _selected;
  DestinationEntity? get selected => _selected;

  Future<void> loadDestinations({String? tipo}) async {
    _status = MapStatus.loading;
    _routePoints = [];
    _selected = null;
    notifyListeners();

    try {
      _destinations = await _getDestinations(tipo: tipo);
      _status = MapStatus.loaded;
    } catch (_) {
      _status = MapStatus.error;
    }
    notifyListeners();
  }

  void selectDestination(DestinationEntity destino) {
    _selected = destino;
    notifyListeners();
  }

  void clearSelection() {
    _selected = null;
    _routePoints = [];
    notifyListeners();
  }

  Future<void> loadRouteTo(DestinationEntity destino) async {
    // Coordenadas de Chiapas como fallback si no hay GPS
    double originLat = 16.7521;
    double originLng = -93.1152;

    try {
      final permission = await Geolocator.checkPermission();
      final tienePermiso = permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;

      if (tienePermiso) {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 6),
          ),
        );
        originLat = pos.latitude;
        originLng = pos.longitude;
      }
    } catch (_) {
      // Sin GPS: se usa el centro de Chiapas como origen
    }

    try {
      final puntos = await _getRoute(
        originLat: originLat,
        originLng: originLng,
        destLat: destino.lat,
        destLng: destino.lng,
      );
      _routePoints = puntos;
      notifyListeners();
    } catch (_) {}
  }
}
