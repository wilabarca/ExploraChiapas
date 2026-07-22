import '../../../../domain/entities/ubicacion_sugerida.dart';

class UbicacionSugeridaModel extends UbicacionSugerida {
  const UbicacionSugeridaModel({
    required super.id,
    required super.latitude,
    required super.longitude,
    super.address,
    super.municipality,
    super.state,
    required super.createdAt,
  });

  factory UbicacionSugeridaModel.fromJson(Map<String, dynamic> json) {
    return UbicacionSugeridaModel(
      id: json['id'].toString(),
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      address: json['address']?.toString(),
      municipality: json['municipality']?.toString(),
      state: json['state']?.toString(),
      createdAt: DateTime.parse(json['createdAt'].toString()),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }
}
