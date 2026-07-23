import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// Geolocator.requestPermission() habla directo con la Activity nativa
  /// de Android para mostrar el diálogo de permiso. Si se llama justo
  /// cuando la app está terminando de volver de segundo plano (la
  /// Activity todavía no queda 100% "resumed"), el plugin puede lanzar
  /// una excepción nativa en vez de simplemente esperar — sin este
  /// try/catch, esa excepción no capturada rompía la pantalla.
  Future<LocationPermission> requestPermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return LocationPermission.denied;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      return permission;
    } catch (e) {
      debugPrint('[LocationService] Error al pedir permiso: $e');
      return LocationPermission.denied;
    }
  }

  /// Regresa false si fue denegado (incluyendo deniedForever) o si el
  /// plugin falla al consultarlo.
  Future<bool> hasPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (e) {
      debugPrint('[LocationService] Error al consultar permiso: $e');
      return false;
    }
  }

  Future<Position?> getCurrentPosition() async {
    try {
      final has = await hasPermission();
      if (!has) return null;
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      debugPrint('[LocationService] Error al obtener posición: $e');
      return null;
    }
  }

  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }

  Future<void> openSettings() => Geolocator.openAppSettings();
}
