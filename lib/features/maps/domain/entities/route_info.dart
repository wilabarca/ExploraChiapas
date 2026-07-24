/// Una ruta calculada por OSRM: puntos a dibujar + distancia/duración
/// reales devueltas por el propio servicio de ruteo (antes se descartaban,
/// solo se usaban las coordenadas de la geometría).
class RouteInfo {
  final List<List<double>> points;
  final double distanceMeters;
  final double durationSeconds;

  const RouteInfo({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
  });

  double get distanceKm => distanceMeters / 1000;

  int get durationMinutes => (durationSeconds / 60).round();

  String get distanceText => distanceKm < 1
      ? '${distanceMeters.round()} m'
      : '${distanceKm.toStringAsFixed(1)} km';

  String get durationText {
    final minutos = durationMinutes;
    if (minutos < 60) return '$minutos min';
    final h = minutos ~/ 60;
    final m = minutos % 60;
    return m == 0 ? '${h} h' : '${h} h $m min';
  }
}
