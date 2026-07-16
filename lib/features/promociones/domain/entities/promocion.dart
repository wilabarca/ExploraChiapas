enum PromocionEstado { proxima, vigente, finalizada }

class PromocionEntity {
  final String id;
  final String titulo;
  final String descripcion;
  final double precio;
  final String negocioId;
  final String negocioNombre;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final bool activo;
  final DateTime fechaCreacion;

  const PromocionEntity({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.precio,
    required this.negocioId,
    required this.negocioNombre,
    required this.fechaInicio,
    required this.fechaFin,
    required this.activo,
    required this.fechaCreacion,
  });

  // ── Estado calculado a partir de las fechas y el flag 'activo' ─────────
  PromocionEstado get estado {
    if (!activo) return PromocionEstado.finalizada;

    final ahora = DateTime.now();
    if (ahora.isBefore(fechaInicio)) return PromocionEstado.proxima;
    if (ahora.isAfter(fechaFin)) return PromocionEstado.finalizada;
    return PromocionEstado.vigente;
  }

  String get precioFormateado => '\$${precio.toStringAsFixed(0)}';

  static const _meses = [
    'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
  ];

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day} ${_meses[fecha.month - 1]}';
  }

  String get rangoFechasFormateado {
    return '${_formatearFecha(fechaInicio)} - ${_formatearFecha(fechaFin)}';
  }
}