class EventoEntity {
  final String id;
  final String titulo;
  final String descripcion;
  final DateTime fechaInicio;
  final DateTime? fechaFin;
  final String ubicacion;
  final String categoria;
  final String imageUrl;
  final bool activo;
  final String creadoPor;

  const EventoEntity({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.fechaInicio,
    this.fechaFin,
    required this.ubicacion,
    required this.categoria,
    required this.imageUrl,
    this.activo = true,
    this.creadoPor = 'Admin',
  });

  String get fechaFormateada {
    final meses = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${fechaInicio.day} ${meses[fechaInicio.month - 1]} ${fechaInicio.year}';
  }
}