class UbicacionPropuesta {
  final String? id;
  final double latitude;
  final double longitude;
  final String address;
  final String municipality;
  final String state;
  final String mapProvider;

  const UbicacionPropuesta({
    this.id,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.municipality,
    required this.state,
    this.mapProvider = 'openstreetmap',
  });
}
