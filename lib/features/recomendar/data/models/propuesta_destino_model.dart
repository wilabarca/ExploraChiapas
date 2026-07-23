import '../../domain/entities/propuesta_destino.dart';
import 'imagen_propuesta_model.dart';
import 'ubicacion_propuesta_model.dart';

class PropuestaDestinoModel extends PropuestaDestino {
  const PropuestaDestinoModel({
    required super.id,
    required super.name,
    super.description,
    required super.categoryId,
    super.categoryName,
    required super.locationId,
    super.location,
    required super.status,
    super.rejectionReason,
    super.createdDestinationId,
    super.images,
    super.createdAt,
  });

  factory PropuestaDestinoModel.fromJson(Map<String, dynamic> json) {
    final locationJson = json['location'];
    final imagesJson = json['images'];

    DateTime? createdAt;
    final raw = json['createdAt'] ?? json['created_at'];
    if (raw != null) {
      createdAt = DateTime.tryParse(raw.toString());
    }

    return PropuestaDestinoModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      categoryId: json['categoryId']?.toString() ?? '',
      categoryName: json['categoryName']?.toString(),
      locationId: json['locationId']?.toString() ?? '',
      location: locationJson is Map<String, dynamic>
          ? UbicacionPropuestaModel.fromJson(locationJson)
          : null,
      status: json['status']?.toString() ?? 'pendiente',
      rejectionReason: json['rejectionReason']?.toString(),
      createdDestinationId: json['createdDestinationId']?.toString(),
      images: imagesJson is List
          ? imagesJson
              .whereType<Map<String, dynamic>>()
              .map(ImagenPropuestaModel.fromJson)
              .toList()
          : const [],
      createdAt: createdAt,
    );
  }
}
