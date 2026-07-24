class DestinationEntity {
  final String id;
  final String nombre;
  final String tipo; // naturaleza, cultura, gastronomía, etc.
  final String descripcion;
  final double lat;
  final double lng;
  final double calificacion;
  final int afluencia; // 1-100, usado para alertas de saturación
  final bool esSostenible;
  final bool esMock; // true si viene del fallback local, no del backend
  // UUID real de categoría del backend (null en el mock local) — se usa
  // para saber si un destino coincide con los intereses guardados del
  // usuario, sin depender del slug de texto `tipo`.
  final String? categoryId;

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
    this.categoryId,
  });
}
