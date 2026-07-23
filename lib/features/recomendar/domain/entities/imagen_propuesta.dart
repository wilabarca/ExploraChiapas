class ImagenPropuesta {
  final String id;
  final String imageUrl;
  final int order;
  final DateTime? createdAt;

  const ImagenPropuesta({
    required this.id,
    required this.imageUrl,
    required this.order,
    this.createdAt,
  });
}
