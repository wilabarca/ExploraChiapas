class Evento {
  final String id;
  final String titulo;
  final String? descripcion;

  final DateTime fechaInicio;
  final DateTime? fechaFin;

  final String? ubicacionId;
  final String? categoriaId;
  final String? categoriaNombre;
  final String? municipio;

  final bool activo;
  final DateTime fechaCreacion;

  const Evento({
    required this.id,
    required this.titulo,
    this.descripcion,
    required this.fechaInicio,
    this.fechaFin,
    this.ubicacionId,
    this.categoriaId,
    this.categoriaNombre,
    this.municipio,
    required this.activo,
    required this.fechaCreacion,
  });
}