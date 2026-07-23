import '../../../../domain/entities/propuesta_destino.dart';

class PropuestaUbicacionModel extends PropuestaUbicacion {
  const PropuestaUbicacionModel({
    required super.id,
    required super.latitude,
    required super.longitude,
    super.address,
    super.municipality,
    super.state,
    super.mapProvider,
  });

  factory PropuestaUbicacionModel.fromJson(Map<String, dynamic> json) {
    return PropuestaUbicacionModel(
      id: json['id'].toString(),
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      address: json['address']?.toString(),
      municipality: json['municipality']?.toString(),
      state: json['state']?.toString(),
      mapProvider: json['mapProvider']?.toString(),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? double.nan;
  }
}

class PropuestaDestinoImagenModel extends PropuestaDestinoImagen {
  const PropuestaDestinoImagenModel({
    required super.id,
    required super.imageUrl,
    required super.order,
    required super.createdAt,
  });

  factory PropuestaDestinoImagenModel.fromJson(Map<String, dynamic> json) {
    return PropuestaDestinoImagenModel(
      id: json['id'].toString(),
      imageUrl: json['imageUrl']?.toString() ?? '',
      order: _parseInt(json['order']),
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class PropuestaDestinoModel extends PropuestaDestino {
  const PropuestaDestinoModel({
    required super.id,
    super.userId,
    required super.name,
    super.description,
    required super.categoryId,
    required super.categoryName,
    required super.locationId,
    required super.location,
    required super.status,
    super.rejectionReason,
    super.reviewedBy,
    super.reviewedAt,
    super.createdDestinationId,
    required super.createdAt,
    required super.updatedAt,
    super.images,
  });

  factory PropuestaDestinoModel.fromJson(Map<String, dynamic> json) {
    final locationJson = json['location'];

    return PropuestaDestinoModel(
      id: json['id'].toString(),
      userId: json['userId']?.toString(),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      categoryId: json['categoryId']?.toString() ?? '',
      categoryName: json['categoryName']?.toString() ?? '',
      locationId: json['locationId']?.toString() ?? '',
      location: locationJson is Map<String, dynamic>
          ? PropuestaUbicacionModel.fromJson(locationJson)
          : const PropuestaUbicacionModel(
              id: '',
              latitude: double.nan,
              longitude: double.nan,
            ),
      status: estadoPropuestaDesdeTexto(json['status']?.toString()),
      rejectionReason: json['rejectionReason']?.toString(),
      reviewedBy: json['reviewedBy']?.toString(),
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.tryParse(json['reviewedAt'].toString())
          : null,
      createdDestinationId: json['createdDestinationId']?.toString(),
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
      images: (json['images'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(PropuestaDestinoImagenModel.fromJson)
          .toList(growable: false),
    );
  }
}
