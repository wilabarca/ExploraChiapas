import '../../../../domain/entities/negocio_servicio.dart';

class NegocioServicioModel extends NegocioServicio {
  const NegocioServicioModel({
    required super.id,
    required super.negocioId,
    required super.nombre,
  });

  factory NegocioServicioModel.fromJson(Map<String, dynamic> json) {
    return NegocioServicioModel(
      id: json['id'] as String,
      negocioId: json['negocioId'] as String,
      nombre: json['nombre'] as String,
    );
  }
}
