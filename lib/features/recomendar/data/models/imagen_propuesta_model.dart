import '../../domain/entities/imagen_propuesta.dart';

class ImagenPropuestaModel extends ImagenPropuesta {
  const ImagenPropuestaModel({
    required super.id,
    required super.imageUrl,
    required super.order,
    super.createdAt,
  });

  factory ImagenPropuestaModel.fromJson(Map<String, dynamic> json) {
    DateTime? createdAt;
    final raw = json['createdAt'] ?? json['created_at'];
    if (raw != null) {
      createdAt = DateTime.tryParse(raw.toString());
    }

    return ImagenPropuestaModel(
      id: json['id']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? json['image_url']?.toString() ?? '',
      order: _parseInt(json['order']) ?? 0,
      createdAt: createdAt,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}
