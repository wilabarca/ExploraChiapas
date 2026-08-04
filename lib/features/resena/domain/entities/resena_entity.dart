/// Entidad de dominio para una reseña individual.
/// Coincide exactamente con la respuesta real de GET /v1/api/reviews:
/// { id, userId, userName, userImageUrl, targetType, targetId, rating,
///   comment, createdAt }
class Resena {
  final String id;
  final String userId;
  final String? userName;
  final String? userImageUrl;
  final String targetType; // 'destination' | 'business' | 'location'
  final String targetId;
  final int rating; // 1..5
  final String? comment;
  final DateTime createdAt;

  const Resena({
    required this.id,
    required this.userId,
    this.userName,
    this.userImageUrl,
    required this.targetType,
    required this.targetId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });
}
