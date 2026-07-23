import '../../domain/entities/ubicacion_propuesta.dart';

class UbicacionPropuestaModel extends UbicacionPropuesta {
  const UbicacionPropuestaModel({
    super.id,
    required super.latitude,
    required super.longitude,
    required super.address,
    required super.municipality,
    required super.state,
    super.mapProvider,
  });

  factory UbicacionPropuestaModel.fromJson(Map<String, dynamic> json) {
    return UbicacionPropuestaModel(
      id: json['id']?.toString(),
      latitude: _parseDouble(json['latitude']) ?? 0.0,
      longitude: _parseDouble(json['longitude']) ?? 0.0,
      address: json['address']?.toString() ?? '',
      municipality: json['municipality']?.toString() ?? '',
      state: json['state']?.toString() ?? 'Chiapas',
      mapProvider: json['mapProvider']?.toString() ?? 'openstreetmap',
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
