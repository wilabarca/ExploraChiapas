import '../../../../../../core/utils/media_url_resolver.dart';
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
    // Backend uses English camelCase; some older responses use Spanish — support both.
    final nombre = (json['name'] ?? json['nombre'])?.toString() ?? '';
    final descripcion =
        (json['description'] ?? json['descripcion'])?.toString() ?? '';
    final direccion =
        (json['address'] ?? json['direccion'])?.toString() ?? '';
    final tipoNegocioId =
        (json['businessTypeId'] ?? json['tipoNegocioId'])?.toString() ?? '';

    // businessType may be a nested object { id, name } or a flat string field.
    String tipoNegocioNombre;
    if (json['businessType'] is Map) {
      tipoNegocioNombre =
          (json['businessType'] as Map<String, dynamic>)['name']?.toString() ??
          '';
    } else {
      tipoNegocioNombre =
          (json['businessTypeName'] ?? json['tipoNegocioNombre'])?.toString() ??
          '';
    }

    final latitud =
        ((json['latitude'] ?? json['lat'] ?? json['latitud']) as num?)
            ?.toDouble() ??
        0.0;
    final longitud =
        ((json['longitude'] ?? json['lng'] ?? json['longitud']) as num?)
            ?.toDouble() ??
        0.0;
    final precioDesde =
        ((json['priceFrom'] ?? json['precioDesde']) as num?)?.toDouble();
    final imagenPrincipal = resolveMediaUrl(
          (json['imageUrl'] ?? json['mainImage'] ?? json['imagenPrincipal'])
              ?.toString(),
        ) ??
        '';
    final verificado =
        (json['isVerified'] ?? json['verificado']) as bool? ?? false;
    final calificacionPromedio =
        ((json['averageRating'] ?? json['calificacionPromedio']) as num?)
            ?.toDouble() ??
        0.0;
    final numeroResenas =
        ((json['totalReviews'] ?? json['numeroResenas']) as num?)?.toInt() ?? 0;
    final esFavorito =
        (json['isFavorite'] ?? json['esFavorito']) as bool? ?? false;

    final imagenes = ((json['images'] ?? json['imagenes']) as List<dynamic>? ?? [])
        .map((e) => resolveMediaUrl(e.toString()) ?? '')
        .toList();
    final servicios =
        ((json['services'] ?? json['servicios']) as List<dynamic>? ?? [])
            .map((e) =>
                NegocioServicioModel.fromJson(e as Map<String, dynamic>))
            .toList();
    final horarios =
        ((json['schedules'] ?? json['horarios']) as List<dynamic>? ?? [])
            .map((e) =>
                NegocioHorarioModel.fromJson(e as Map<String, dynamic>))
            .toList();

    return NegocioModel(
      id: json['id'].toString(),
      nombre: nombre,
      descripcion: descripcion,
      direccion: direccion,
      tipoNegocioId: tipoNegocioId,
      tipoNegocioNombre: tipoNegocioNombre,
      latitud: latitud,
      longitud: longitud,
      precioDesde: precioDesde,
      calificacionPromedio: calificacionPromedio,
      numeroResenas: numeroResenas,
      verificado: verificado,
      imagenPrincipal: imagenPrincipal,
      imagenes: imagenes,
      servicios: servicios,
      horarios: horarios,
      promocionesVigentes:
          (json['promocionesVigentes'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toList(),
      esFavorito: esFavorito,
    );
  }
}
