import '../../../../domain/entities/negocio_servicio.dart';

class NegocioServicioModel extends NegocioServicio {
  const NegocioServicioModel({
    required super.id,
    required super.negocioId,
    required super.nombre,
  });

  /// Igual que con horarios: se soportan nombres de campo en inglés
  /// (`businessId`, `name`) además de los españoles asumidos
  /// originalmente, para no volver a romper el detalle si el backend
  /// llega a exponer `services` con esa convención.
  factory NegocioServicioModel.fromJson(Map<String, dynamic> json) {
    return NegocioServicioModel(
      id: json['id']?.toString() ?? '',
      negocioId: (json['businessId'] ?? json['negocioId'])?.toString() ?? '',
      nombre: (json['name'] ?? json['nombre'])?.toString() ?? '',
    );
  }
}
