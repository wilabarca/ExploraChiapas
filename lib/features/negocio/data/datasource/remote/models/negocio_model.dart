import '../../../../domain/entities/negocio.dart';
import 'negocio_horario_model.dart';
import 'negocio_servicio_model.dart';

class NegocioModel extends Negocio {
  const NegocioModel({
    required super.id,
    required super.nombre,
    required super.descripcion,
    required super.direccion,
    required super.tipoNegocioId,
    required super.tipoNegocioNombre,
    required super.latitud,
    required super.longitud,
    super.precioDesde,
    required super.calificacionPromedio,
    required super.numeroResenas,
    super.verificado,
    required super.imagenPrincipal,
    super.imagenes,
    super.servicios,
    super.horarios,
    super.promocionesVigentes,
    super.esFavorito,
  });

  factory NegocioModel.fromJson(Map<String, dynamic> json) {
    return NegocioModel(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String? ?? '',
      direccion: json['direccion'] as String? ?? '',
      tipoNegocioId: json['tipoNegocioId'] as String,
      tipoNegocioNombre: json['tipoNegocioNombre'] as String? ?? '',
      latitud: (json['latitud'] as num?)?.toDouble() ?? 0.0,
      longitud: (json['longitud'] as num?)?.toDouble() ?? 0.0,
      precioDesde: (json['precioDesde'] as num?)?.toDouble(),
      calificacionPromedio:
          (json['calificacionPromedio'] as num?)?.toDouble() ?? 0.0,
      numeroResenas: json['numeroResenas'] as int? ?? 0,
      verificado: json['verificado'] as bool? ?? false,
      imagenPrincipal: json['imagenPrincipal'] as String? ?? '',
      imagenes: (json['imagenes'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      servicios: (json['servicios'] as List<dynamic>? ?? [])
          .map((e) => NegocioServicioModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      horarios: (json['horarios'] as List<dynamic>? ?? [])
          .map((e) => NegocioHorarioModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      promocionesVigentes: (json['promocionesVigentes'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      esFavorito: json['esFavorito'] as bool? ?? false,
    );
  }
}
