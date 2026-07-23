class DestinationEntity {
  final String id;
  final String nombre;
  final String tipo;        // naturaleza, cultura, gastronomía, etc.
  final String descripcion;
  final double lat;
  final double lng;
  final double calificacion;
  final int afluencia;      // 1-100, usado para alertas de saturación
  final bool esSostenible;
  final bool esMock;        // true si viene del fallback local, no del backend

  const DestinationEntity({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.descripcion,
    required this.lat,
    required this.lng,
    required this.calificacion,
    required this.afluencia,
    required this.esSostenible,
    this.esMock = false,
  });
}