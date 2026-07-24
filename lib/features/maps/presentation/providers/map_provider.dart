import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/entities/destination_entity.dart';
import '../../domain/entities/route_info.dart';
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

  List<RouteInfo> _allRoutes = [];
  List<RouteInfo> get allRoutes => _allRoutes;

  int _selectedRouteIndex = 0;
  int get selectedRouteIndex => _selectedRouteIndex;

  bool get hayAlternativas => _allRoutes.length > 1;

  RouteInfo? get selectedRoute =>
      _allRoutes.isEmpty ? null : _allRoutes[_selectedRouteIndex];

  // Puntos del trayecto activo para dibujar en el mapa
  List<List<double>> get routePoints =>
      selectedRoute?.points ?? [];

  String? _routeError;
  String? get routeError => _routeError;

  DestinationEntity? _selected;
  DestinationEntity? get selected => _selected;

  bool _enNavegacion = false;
  bool get enNavegacion => _enNavegacion;

  Position? _userPosition;
  Position? get userPosition => _userPosition;

  double _userHeading = 0;
  double get userHeading => _userHeading;

  StreamSubscription<Position>? _posicionStream;

  Future<void> loadDestinations({String? tipo}) async {
    _status = MapStatus.loading;
    _allRoutes = [];
    _selected = null;
    _selectedRouteIndex = 0;
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
    _allRoutes = [];
    _selectedRouteIndex = 0;
    _detenerNavegacion();
    notifyListeners();
  }

  void selectRoute(int index) {
    if (index < 0 || index >= _allRoutes.length) return;
    _selectedRouteIndex = index;
    notifyListeners();
  }

  Future<bool> loadRouteTo(DestinationEntity destino) async {
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
        _userPosition = pos;
        _userHeading = pos.heading;
      }
    } catch (_) {
      // Sin GPS: se usa el centro de Chiapas como origen por defecto.
    }

    try {
      final rutas = await _getRoute(
        originLat: originLat,
        originLng: originLng,
        destLat: destino.lat,
        destLng: destino.lng,
      );
      _allRoutes = rutas;
      _selectedRouteIndex = 0;
      _routeError = null;
      notifyListeners();
    } catch (e) {
      _allRoutes = [];
      _routeError = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }

    _iniciarNavegacion();
    return true;
  }

  void _iniciarNavegacion() {
    _posicionStream?.cancel();
    _enNavegacion = true;
    notifyListeners();

    _posicionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 3,
      ),
    ).listen((pos) {
      _userPosition = pos;
      _userHeading = pos.heading;
      notifyListeners();
    });
  }

  void _detenerNavegacion() {
    _posicionStream?.cancel();
    _posicionStream = null;
    _enNavegacion = false;
    _userPosition = null;
    _userHeading = 0;
  }

  @override
  void dispose() {
    _posicionStream?.cancel();
    super.dispose();
  }
}
