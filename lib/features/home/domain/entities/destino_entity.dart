class DestinoEntity {
  final String id;
  final String nombre;
  final String categoria;
  final double calificacion;
  final String imageUrl;
  final double lat;
  final double lng;
  final bool esFavorito;

  const DestinoEntity({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.calificacion,
    required this.imageUrl,
    required this.lat,
    required this.lng,
    this.esFavorito = false,
  });
}