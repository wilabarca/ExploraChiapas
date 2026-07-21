import '../../../../domain/entities/destino.dart';

class DestinoModel extends Destino {
  const DestinoModel({
    required super.id,
    required super.name,
    super.description,
    required super.categoryId,
    required super.locationId,
    required super.active,
    required super.createdAt,
    required super.averageRating,
    required super.totalReviews,
    required super.isSaturated,
    super.imageUrl,
  });

  factory DestinoModel.fromJson(Map<String, dynamic> json) {
    return DestinoModel(
      id: json['id'].toString(),
      name: json['name'].toString(),
      description: json['description']?.toString(),
      categoryId: json['categoryId'].toString(),
      locationId: json['locationId'].toString(),
      active: _parseBool(json['active']),
      createdAt: DateTime.parse(json['createdAt'].toString()),
      averageRating: _parseDouble(json['averageRating']),
      totalReviews: _parseInt(json['totalReviews']),
      isSaturated: _parseBool(json['isSaturated']),
      imageUrl: json['imageUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'categoryId': categoryId,
      'locationId': locationId,
      'active': active,
      'createdAt': createdAt.toIso8601String(),
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'isSaturated': isSaturated,
    };
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    if (value is String) {
      final normalizedValue = value.toLowerCase().trim();

      return normalizedValue == 'true' ||
          normalizedValue == '1' ||
          normalizedValue == 'yes';
    }

    return false;
  }

  static double _parseDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}