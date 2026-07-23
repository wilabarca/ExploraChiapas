/// Estado de revisión de una propuesta de destino ("Recomendar lugar").
/// El usuario nunca puede fijarlo: siempre nace `pendiente` y solo un
/// administrador de plataforma la mueve a `aprobada`/`rechazada`.
enum EstadoPropuestaDestino { pendiente, aprobada, rechazada }

EstadoPropuestaDestino estadoPropuestaDesdeTexto(String? valor) {
  switch (valor) {
    case 'aprobada':
      return EstadoPropuestaDestino.aprobada;
    case 'rechazada':
      return EstadoPropuestaDestino.rechazada;
    case 'pendiente':
    default:
      // Cualquier valor desconocido se trata como pendiente en vez de
      // fallar: es el estado más conservador (no permite navegar a un
      // destino que no existe ni muestra un motivo de rechazo falso).
      return EstadoPropuestaDestino.pendiente;
  }
}

/// Ubicación real asociada a una propuesta (tabla `ubicacion`), la misma
/// que crea `POST /v1/api/locations` antes de crear la propuesta.
class PropuestaUbicacion {
  final String id;
  final double latitude;
  final double longitude;
  final String? address;
  final String? municipality;
  final String? state;
  final String? mapProvider;

  const PropuestaUbicacion({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.address,
    this.municipality,
    this.state,
    this.mapProvider,
  });

  /// Texto corto tipo "Suchiapa, Chiapas" para mostrar bajo el nombre.
  String get resumen {
    final partes = [
      if (municipality != null && municipality!.trim().isNotEmpty)
        municipality!.trim(),
      if (state != null && state!.trim().isNotEmpty) state!.trim(),
    ];
    if (partes.isNotEmpty) return partes.join(', ');
    if (address != null && address!.trim().isNotEmpty) return address!.trim();
    return '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';
  }
}

/// Una fotografía subida para una propuesta de destino.
class PropuestaDestinoImagen {
  final String id;
  final String imageUrl;
  final int order;
  final DateTime createdAt;

  const PropuestaDestinoImagen({
    required this.id,
    required this.imageUrl,
    required this.order,
    required this.createdAt,
  });
}

/// Propuesta de un nuevo destino turístico enviada por un usuario a
/// través de "Recomendar lugar". No es una entidad `Destino`: hasta que
/// no la aprueba un admin_plataforma, el lugar no existe oficialmente en
/// ExploraChiapas (no aparece en Explorar, mapa, favoritos ni reseñas).
class PropuestaDestino {
  final String id;
  final String? userId;
  final String name;
  final String? description;
  final String categoryId;
  final String categoryName;
  final String locationId;
  final PropuestaUbicacion location;
  final EstadoPropuestaDestino status;
  final String? rejectionReason;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? createdDestinationId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<PropuestaDestinoImagen> images;

  const PropuestaDestino({
    required this.id,
    this.userId,
    required this.name,
    this.description,
    required this.categoryId,
    required this.categoryName,
    required this.locationId,
    required this.location,
    required this.status,
    this.rejectionReason,
    this.reviewedBy,
    this.reviewedAt,
    this.createdDestinationId,
    required this.createdAt,
    required this.updatedAt,
    this.images = const [],
  });

  /// Primera foto (por `order`) o `null` si todavía no tiene ninguna.
  /// Es la misma que el backend usará como portada al aprobar.
  PropuestaDestinoImagen? get fotoPrincipal {
    if (images.isEmpty) return null;
    final ordenadas = [...images]..sort((a, b) => a.order.compareTo(b.order));
    return ordenadas.first;
  }
}
