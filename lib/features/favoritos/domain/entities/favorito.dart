class Favorito {
  final String userId;
  final String targetType;
  final String targetId;
  final DateTime? addedAt;

  const Favorito({
    required this.userId,
    required this.targetType,
    required this.targetId,
    this.addedAt,
  });
}
