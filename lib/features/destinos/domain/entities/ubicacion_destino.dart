/// Ubicación real de un destino (tabla `ubicacion` del backend), obtenida
/// vía `GET /locations/{locationId}`. Nunca se generan o simulan
/// coordenadas: si el backend no la tiene, no hay a dónde navegar.
class UbicacionDestino {
  final String id;
  final double latitude;
  final double longitude;
  final String? address;
  final String? municipality;
  final String? state;
  final String? mapProvider;

  const UbicacionDestino({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.address,
    this.municipality,
    this.state,
    this.mapProvider,
  });

  bool get tieneCoordenadasValidas =>
      latitude >= -90 &&
      latitude <= 90 &&
      longitude >= -180 &&
      longitude <= 180 &&
      !(latitude == 0 && longitude == 0);

  String get direccionResumida {
    final partes = [
      if (address != null && address!.trim().isNotEmpty) address!.trim(),
      if (municipality != null && municipality!.trim().isNotEmpty)
        municipality!.trim(),
      if (state != null && state!.trim().isNotEmpty) state!.trim(),
    ];
    return partes.join(', ');
  }
}
