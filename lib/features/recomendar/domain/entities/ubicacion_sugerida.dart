/// Ubicación sugerida por un usuario a través de "Recomendar lugar".
/// Corresponde 1:1 a la fila que el backend crea en la tabla `ubicacion`
/// vía POST /v1/api/locations — SIEMPRE con origen "usuario" y estado de
/// revisión "pendiente" (el backend lo asigna automáticamente; ningún
/// campo de este flujo permite marcarla como ya aprobada).
class UbicacionSugerida {
  final String id;
  final double latitude;
  final double longitude;
  final String? address;
  final String? municipality;
  final String? state;
  final DateTime createdAt;

  const UbicacionSugerida({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.address,
    this.municipality,
    this.state,
    required this.createdAt,
  });
}
