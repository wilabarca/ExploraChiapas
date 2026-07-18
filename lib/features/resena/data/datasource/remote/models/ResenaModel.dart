import '../../../../domain/entities/resena_entity.dart';

class ResenaModel extends Resena {
  const ResenaModel({
    required super.id,
    required super.userId,
    required super.targetType,
    required super.targetId,
    required super.rating,
    super.comment,
    required super.createdAt,
  });

  factory ResenaModel.fromJson(Map<String, dynamic> json) {
    return ResenaModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      targetType: json['targetType'] as String,
      targetId: json['targetId'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
