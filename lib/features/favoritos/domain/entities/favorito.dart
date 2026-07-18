import 'package:equatable/equatable.dart';

class FavoritoTargetType {
  static const String destination = 'destination';
  static const String business = 'business';
  static const String restaurant = 'restaurant';
  static const String hotel = 'hotel';
  static const String event = 'event';
}

class Favorito extends Equatable {
  final String id;
  final String userId;
  final String targetType;
  final String targetId;
  final String? targetName;
  final String? targetImageUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Favorito({
    required this.id,
    required this.userId,
    required this.targetType,
    required this.targetId,
    this.targetName,
    this.targetImageUrl,
    required this.createdAt,
    this.updatedAt,
  });

  Favorito copyWith({
    String? id,
    String? userId,
    String? targetType,
    String? targetId,
    String? targetName,
    String? targetImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Favorito(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      targetName: targetName ?? this.targetName,
      targetImageUrl: targetImageUrl ?? this.targetImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        targetType,
        targetId,
        targetName,
        targetImageUrl,
        createdAt,
        updatedAt,
      ];
}