import '../../../../domain/entities/promocion.dart';

class PromocionModel extends PromocionEntity {
  const PromocionModel({
    required super.id,
    required super.titulo,
    required super.descripcion,
    required super.precio,
    required super.negocioId,
    required super.negocioNombre,
    required super.fechaInicio,
    required super.fechaFin,
    required super.activo,
    required super.fechaCreacion,
  });

  factory PromocionModel.fromJson(Map<String, dynamic> json) {
    return PromocionModel(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String? ?? '',
      precio: (json['precio'] as num?)?.toDouble() ?? 0.0,
      negocioId: json['negocioId'] as String,
      negocioNombre: json['negocioNombre'] as String? ?? '',
      fechaInicio: DateTime.parse(json['fechaInicio'] as String),
      fechaFin: DateTime.parse(json['fechaFin'] as String),
      activo: json['activo'] as bool? ?? true,
      fechaCreacion: DateTime.parse(json['fechaCreacion'] as String),
    );
  }
}
