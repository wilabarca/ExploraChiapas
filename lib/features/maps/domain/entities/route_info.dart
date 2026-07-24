class RouteInfo {
  final List<List<double>> points;
  final int durationMinutes;
  final double distanceKm;

  const RouteInfo({
    required this.points,
    required this.durationMinutes,
    required this.distanceKm,
  });
}
