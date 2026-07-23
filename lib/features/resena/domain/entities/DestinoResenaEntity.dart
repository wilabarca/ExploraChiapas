/// Representa un lugar que puede recibir reseñas (destino o negocio).
///
/// `targetType` se recibe explícito desde quien construye la entidad, en
/// vez de inferirse a partir del nombre de categoría mostrado en pantalla
/// (heurística anterior: "Restaurante"/"Hotel" = negocio, cualquier otra
/// cosa = destino). Esa heurística fallaba con categorías reales que no
/// están en esa lista corta (p. ej. un negocio categorizado como
/// "Gastronomía"), y no tenía forma de representar un lugar que no
/// corresponde a ninguna fila real del backend (recomendaciones del motor
/// ML o del chat), que no puede recibir reseñas.
class DestinoResenaEntity {
  final String id; // targetId real (UUID) para la API de reseñas
  final String nombre;
  final String ubicacion;
  final String imageUrl;
  final bool esPopular;
  final double calificacion;
  final int totalResenas;
  final String tipo; // Etiqueta de categoría, solo para mostrar en UI.
  final String targetType; // 'destination' | 'business' | 'location'

  const DestinoResenaEntity({
    required this.id,
    required this.nombre,
    required this.ubicacion,
    required this.imageUrl,
    required this.calificacion,
    required this.totalResenas,
    required this.tipo,
    required this.targetType,
    this.esPopular = false,
  });
}
