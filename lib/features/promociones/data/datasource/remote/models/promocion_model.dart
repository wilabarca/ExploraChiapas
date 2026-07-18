import '../../../../domain/entities/promocion.dart';

class PromocionModel extends PromocionEntity {
  const PromocionModel({
    required super.id,
    required super.titulo,
    super.descripcion,
    super.imagenUrl,
    super.precio,
    required super.negocioId,
    super.negocioNombre,
    required super.fechaInicio,
    super.fechaFin,
    required super.activo,
    required super.fechaCreacion,
  });

  factory PromocionModel.fromJson(Map<String, dynamic> json) {
    return PromocionModel(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String?,
      imagenUrl: json['imagenUrl'] as String?,
      precio: (json['precio'] as num?)?.toDouble(),
      negocioId: json['negocioId'] as String,
      negocioNombre: json['negocioNombre'] as String?,
      fechaInicio: DateTime.parse(json['fechaInicio'] as String),
      fechaFin: json['fechaFin'] != null
          ? DateTime.parse(json['fechaFin'] as String)
          : null,
      activo: json['activo'] as bool? ?? true,
      fechaCreacion: DateTime.parse(json['fechaCreacion'] as String),
    );
  }
}
