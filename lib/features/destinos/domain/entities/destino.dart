class Destino {
  final String id;
  final String name;
  final String? description;
  final String categoryId;
  final String locationId;
  final bool active;
  final DateTime createdAt;
  final double averageRating;
  final int totalReviews;
  final bool isSaturated;

  const Destino({
    required this.id,
    required this.name,
    this.description,
    required this.categoryId,
    required this.locationId,
    required this.active,
    required this.createdAt,
    required this.averageRating,
    required this.totalReviews,
    required this.isSaturated,
  });
}