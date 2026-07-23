import 'imagen_propuesta.dart';
import 'ubicacion_propuesta.dart';

class PropuestaDestino {
  final String id;
  final String name;
  final String? description;
  final String categoryId;
  final String? categoryName;
  final String locationId;
  final UbicacionPropuesta? location;
  final String status;
  final String? rejectionReason;
  final String? createdDestinationId;
  final List<ImagenPropuesta> images;
  final DateTime? createdAt;

  const PropuestaDestino({
    required this.id,
    required this.name,
    this.description,
    required this.categoryId,
    this.categoryName,
    required this.locationId,
    this.location,
    required this.status,
    this.rejectionReason,
    this.createdDestinationId,
    this.images = const [],
    this.createdAt,
  });
}
