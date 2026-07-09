import '../../domain/entities/evento.dart';

class EventoModel extends Evento {
  const EventoModel({
    required super.id,
    required super.titulo,
    super.descripcion,
    super.fechaInicio,
    super.fechaFin,
    super.ubicacionId,
    super.categoriaId,
    super.categoriaNombre,
    super.municipio,
    required super.activo,
    super.fechaCreacion,
  });

  factory EventoModel.fromJson(Map<String, dynamic> json) => EventoModel(
        id: json['id']?.toString() ?? '',
        titulo: (json['titulo'] ?? json['title'] ?? '').toString(),
        descripcion: (json['descripcion'] ?? json['description'])?.toString(),
        fechaInicio: _date(json['fechaInicio'] ?? json['fecha_inicio'] ?? json['startDate']),
        fechaFin: _date(json['fechaFin'] ?? json['fecha_fin'] ?? json['endDate']),
        ubicacionId: (json['ubicacionId'] ?? json['ubicacion_id'] ?? json['locationId'])?.toString(),
        categoriaId: (json['categoriaId'] ?? json['categoria_id'] ?? json['categoryId'])?.toString(),
        categoriaNombre: (json['categoriaNombre'] ?? json['categoria_nombre'] ?? json['categoryName'])?.toString(),
        municipio: (json['municipio'] ?? json['municipality'])?.toString(),
        activo: _bool(json['activo'] ?? json['active'], fallback: true),
        fechaCreacion: _date(json['fechaCreacion'] ?? json['fecha_creacion'] ?? json['createdAt']),
      );

  static DateTime? _date(dynamic value) =>
      value == null ? null : DateTime.tryParse(value.toString());

  static bool _bool(dynamic value, {bool fallback = false}) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) return value == '1' || value.toLowerCase() == 'true';
    return fallback;
  }
}
