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

  /// Id de la ubicación real del evento en el backend (tabla `ubicacion`).
  /// `null` si el evento no tiene ubicación asignada; en ese caso no se
  /// puede trazar ruta hacia él.
  final String? ubicacionId;

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
    this.ubicacionId,
  });

  static const _meses = [
    'Ene',
    'Feb',
    'Mar',
    'Abr',
    'May',
    'Jun',
    'Jul',
    'Ago',
    'Sep',
    'Oct',
    'Nov',
    'Dic',
  ];

  String _formatear(DateTime fecha) {
    return '${fecha.day} ${_meses[fecha.month - 1]} ${fecha.year}';
  }

  String get fechaFormateada => _formatear(fechaInicio);

  /// Evita tener que instanciar un EventoEntity temporal solo para
  /// formatear la fecha de cierre.
  String? get fechaFinFormateada {
    if (fechaFin == null) return null;
    return _formatear(fechaFin!);
  }
}
