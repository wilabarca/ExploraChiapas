import '../../domain/entities/favorito.dart';

class FavoritoModel extends Favorito {
  const FavoritoModel({
    required super.userId,
    required super.targetType,
    required super.targetId,
    super.addedAt,
  });

  factory FavoritoModel.fromJson(Map<String, dynamic> json) => FavoritoModel(
        userId: (json['userId'] ?? json['user_id'] ?? json['usuarioId'] ?? '').toString(),
        targetType: (json['targetType'] ?? json['target_type'] ?? json['tipoObjetivo'] ?? '').toString(),
        targetId: (json['targetId'] ?? json['target_id'] ?? json['objetivoId'] ?? '').toString(),
        addedAt: DateTime.tryParse(
          (json['addedAt'] ?? json['added_at'] ?? json['fechaAgregado'] ?? '').toString(),
        ),
      );
}
