/// Entidad de dominio para una reseña individual.
/// Coincide exactamente con la respuesta real de GET /v1/api/reviews:
/// { id, userId, targetType, targetId, rating, comment, createdAt }
class Resena {
  final String id;
  final String userId;
  final String targetType; // 'destination' | 'business' | 'location'
  final String targetId;
  final int rating; // 1..5
  final String? comment;
  final DateTime createdAt;

  const Resena({
    required this.id,
    required this.userId,
    required this.targetType,
    required this.targetId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });
}