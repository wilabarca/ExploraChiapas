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
    // Backend uses English camelCase; mock uses Spanish — support both.
    final nombre = (json['name'] ?? json['nombre'])?.toString() ?? '';
    final descripcion =
        (json['description'] ?? json['descripcion'])?.toString() ?? '';
    final tipoNegocioId =
        (json['businessTypeId'] ?? json['tipoNegocioId'])?.toString() ?? '';
    final precioDesde =
        ((json['priceFrom'] ?? json['precioDesde']) as num?)?.toDouble();
    final imagenPrincipal =
        (json['imageUrl'] ?? json['imagenPrincipal'])?.toString() ?? '';
    final verificado =
        (json['isVerified'] ?? json['verificado']) as bool? ?? false;
    final calificacionPromedio =
        ((json['averageRating'] ?? json['calificacionPromedio']) as num?)
            ?.toDouble() ??
        0.0;
    final numeroResenas =
        ((json['totalReviews'] ?? json['numeroResenas']) as num?)?.toInt() ?? 0;

    return NegocioModel(
      id: json['id'].toString(),
      nombre: nombre,
      descripcion: descripcion,
      direccion: json['direccion']?.toString() ?? '',
      tipoNegocioId: tipoNegocioId,
      tipoNegocioNombre: json['tipoNegocioNombre']?.toString() ?? '',
      latitud: (json['latitud'] as num?)?.toDouble() ?? 0.0,
      longitud: (json['longitud'] as num?)?.toDouble() ?? 0.0,
      precioDesde: precioDesde,
      calificacionPromedio: calificacionPromedio,
      numeroResenas: numeroResenas,
      verificado: verificado,
      imagenPrincipal: imagenPrincipal,
      imagenes: (json['imagenes'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      servicios: (json['servicios'] as List<dynamic>? ?? [])
          .map((e) => NegocioServicioModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      horarios: (json['horarios'] as List<dynamic>? ?? [])
          .map((e) => NegocioHorarioModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      promocionesVigentes: (json['promocionesVigentes'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      esFavorito: json['esFavorito'] as bool? ?? false,
    );
  }
}
