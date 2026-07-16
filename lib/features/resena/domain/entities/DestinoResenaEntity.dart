/// Representa un lugar que puede recibir reseñas (destino o negocio).
///
/// ⚠️ Agregué `id` y `targetType` respecto a tu versión anterior: son
/// obligatorios para llamar a GET/POST /v1/api/reviews (que necesita
/// targetType + targetId). Si tu `resenas_fake_data.dart` no los tiene
/// todavía, agrégalos ahí (o dime y te reescribo ese archivo también).
class DestinoResenaEntity {
  final String id; // targetId real (UUID) para la API de reseñas
  final String nombre;
  final String ubicacion;
  final String imageUrl;
  final bool esPopular;
  final double calificacion;
  final int totalResenas;
  final String tipo; // 'Naturaleza' | 'Cultura' | 'Restaurante' | 'Hotel' ...

  const DestinoResenaEntity({
    required this.id,
    required this.nombre,
    required this.ubicacion,
    required this.imageUrl,
    required this.calificacion,
    required this.totalResenas,
    required this.tipo,
    this.esPopular = false,
  });

  /// La API de reseñas distingue destino turístico vs negocio.
  /// Restaurante/Hotel (y similares) son negocios; el resto son destinos.
  String get targetType {
    const tiposNegocio = {'Restaurante', 'Hotel'};
    return tiposNegocio.contains(tipo) ? 'business' : 'destination';
  }
}