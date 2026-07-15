class ResenaEntity {
  final String id;
  final String autorNombre;
  final String autorTipo;
  final double calificacion;
  final String comentario;
  final String fechaRelativa;
  final List<String> fotos;
  final int likes;
  final int respuestas;

  const ResenaEntity({
    required this.id,
    required this.autorNombre,
    required this.autorTipo,
    required this.calificacion,
    required this.comentario,
    required this.fechaRelativa,
    this.fotos = const [],
    this.likes = 0,
    this.respuestas = 0,
  });
}

class DestinoResenaEntity {
  final String id;
  final String nombre;
  final String ubicacion;
  final String tipo;
  final double calificacion;
  final int totalResenas;
  final String imageUrl;
  final bool esPopular;

  const DestinoResenaEntity({
    required this.id,
    required this.nombre,
    required this.ubicacion,
    required this.tipo,
    required this.calificacion,
    required this.totalResenas,
    required this.imageUrl,
    this.esPopular = false,
  });
}