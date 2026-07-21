import '../../../../domain/entities/destination_entity.dart';

class DestinationModel extends DestinationEntity {
  const DestinationModel({
    required super.id,
    required super.nombre,
    required super.tipo,
    required super.descripcion,
    required super.lat,
    required super.lng,
    required super.calificacion,
    required super.afluencia,
    required super.esSostenible,
    super.esMock,
  });

  factory DestinationModel.fromJson(
    Map<String, dynamic> json, {
    bool esMock = false,
  }) =>
      DestinationModel(
        id: json['id'],
        nombre: json['nombre'],
        tipo: json['tipo'],
        descripcion: json['descripcion'],
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        calificacion: (json['calificacion'] as num).toDouble(),
        afluencia: json['afluencia'],
        esSostenible: json['es_sostenible'] ?? false,
        esMock: esMock,
      );
}