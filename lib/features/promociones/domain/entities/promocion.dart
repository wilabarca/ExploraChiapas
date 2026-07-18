enum PromocionEstado { proxima, vigente, finalizada }

class PromocionEntity {
  final String id;
  final String titulo;
  final String? descripcion;
  final String? imagenUrl;
  final double? precio;
  final String negocioId;
  final String? negocioNombre;
  final DateTime fechaInicio;
  final DateTime? fechaFin;
  final bool activo;
  final DateTime fechaCreacion;

  const PromocionEntity({
    required this.id,
    required this.titulo,
    this.descripcion,
    this.imagenUrl,
    this.precio,
    required this.negocioId,
    this.negocioNombre,
    required this.fechaInicio,
    this.fechaFin,
    required this.activo,
    required this.fechaCreacion,
  });

  // ── Estado calculado a partir de las fechas y el flag 'activo' ─────────
  PromocionEstado get estado {
    if (!activo) return PromocionEstado.finalizada;

    final ahora = DateTime.now();
    if (ahora.isBefore(fechaInicio)) return PromocionEstado.proxima;
    if (fechaFin != null && ahora.isAfter(fechaFin!)) {
      return PromocionEstado.finalizada;
    }
    return PromocionEstado.vigente;
  }

  bool get tieneImagen => imagenUrl != null && imagenUrl!.isNotEmpty;

  bool get tienePrecio => precio != null;

  String get precioFormateado {
    if (precio == null) return 'Gratis';
    return '\$${precio!.toStringAsFixed(0)}';
  }

  String get descripcionMostrable => descripcion ?? '';

  String get negocioMostrable => negocioNombre ?? 'Negocio en Chiapas';

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

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day} ${_meses[fecha.month - 1]}';
  }

  String get rangoFechasFormateado {
    final inicio = _formatearFecha(fechaInicio);
    if (fechaFin == null) return 'Desde $inicio';
    return '$inicio - ${_formatearFecha(fechaFin!)}';
  }
}
