import '../../domain/entities/ubicacion_evento.dart';

class UbicacionEventoModel extends UbicacionEvento {
  const UbicacionEventoModel({
    required super.id,
    required super.latitude,
    required super.longitude,
    super.address,
    super.municipality,
    super.state,
    super.mapProvider,
  });

  factory UbicacionEventoModel.fromJson(Map<String, dynamic> json) {
    return UbicacionEventoModel(
      id: json['id'].toString(),
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      address: _parseOptionalString(json['address']),
      municipality: _parseOptionalString(json['municipality']),
      state: _parseOptionalString(json['state']),
      mapProvider: _parseOptionalString(json['mapProvider']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? double.nan;
  }

  static String? _parseOptionalString(dynamic value) {
    final parsed = value?.toString().trim();
    if (parsed == null || parsed.isEmpty) return null;
    return parsed;
  }
}
