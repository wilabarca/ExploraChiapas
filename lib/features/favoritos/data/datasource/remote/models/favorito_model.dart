import '../../../../domain/entities/favorito.dart';

class FavoritoModel extends Favorito {
  const FavoritoModel({
    required super.id,
    required super.userId,
    required super.targetType,
    required super.targetId,
    super.targetName,
    super.targetImageUrl,
    required super.createdAt,
    super.updatedAt,
  });

  factory FavoritoModel.fromJson(Map<String, dynamic> json) {
    final createdAtValue = json['createdAt'] ?? json['addedAt'];
    final createdAt = createdAtValue != null
        ? DateTime.parse(createdAtValue.toString())
        : DateTime.now();

    return FavoritoModel(
      id:
          json['id']?.toString() ??
          '${json['userId'] ?? ''}-${json['targetType'] ?? ''}-${json['targetId'] ?? ''}',
      userId: json['userId']?.toString() ?? '',
      targetType: json['targetType']?.toString() ?? '',
      targetId: json['targetId']?.toString() ?? '',
      targetName: json['targetName']?.toString(),
      targetImageUrl: json['targetImageUrl']?.toString(),
      createdAt: createdAt,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : null,
    );
  }
}
