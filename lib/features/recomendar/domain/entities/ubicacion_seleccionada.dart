/// Resultado de elegir un punto en [SeleccionarUbicacionMapaPage].
/// `address`/`municipality`/`state` vienen de una geocodificación
/// inversa real (Nominatim/OpenStreetMap) sobre el punto elegido; si esa
/// consulta falla, quedan en `null` — nunca se inventa un municipio o
/// estado para no enviar información falsa al backend.
class UbicacionSeleccionada {
  final double latitude;
  final double longitude;
  final String? address;
  final String? municipality;
  final String? state;

  const UbicacionSeleccionada({
    required this.latitude,
    required this.longitude,
    this.address,
    this.municipality,
    this.state,
  });

  String get resumen {
    final partes = [
      if (municipality != null && municipality!.isNotEmpty) municipality!,
      if (state != null && state!.isNotEmpty) state!,
    ];
    if (partes.isNotEmpty) return partes.join(', ');
    return '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';
  }
}
