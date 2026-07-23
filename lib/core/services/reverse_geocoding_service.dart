import 'package:dio/dio.dart';

/// Resultado de una geocodificación inversa real (Nominatim/OpenStreetMap)
/// sobre un par de coordenadas. Cualquier campo puede venir `null` si el
/// proveedor no lo devuelve — nunca se rellena con un valor inventado.
class DireccionInversa {
  final String? address;
  final String? municipality;
  final String? state;

  const DireccionInversa({this.address, this.municipality, this.state});
}

/// Traduce lat/lng a una dirección aproximada real usando el servicio
/// público de Nominatim (mismo proyecto OpenStreetMap que ya provee los
/// tiles del mapa de la app — no se agrega un proveedor nuevo).
class ReverseGeocodingService {
  Future<DireccionInversa?> buscar({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await Dio().get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'format': 'jsonv2',
          'lat': latitude,
          'lon': longitude,
          'addressdetails': 1,
          'zoom': 16,
        },
        options: Options(
          headers: {'User-Agent': 'com.explorachiapas.app'},
          receiveTimeout: const Duration(seconds: 6),
          sendTimeout: const Duration(seconds: 6),
        ),
      );

      final data = response.data;
      if (data is! Map) return null;

      final address = data['address'];
      if (address is! Map) return null;

      final municipio =
          address['municipality'] ??
          address['city'] ??
          address['town'] ??
          address['village'] ??
          address['county'];
      final estado = address['state'];
      final direccionCorta = data['display_name']?.toString();

      return DireccionInversa(
        address: direccionCorta,
        municipality: municipio?.toString(),
        state: estado?.toString(),
      );
    } catch (_) {
      // Sin conexión, timeout o respuesta inesperada: la ubicación sigue
      // siendo válida solo con coordenadas, que ya son un dato real.
      return null;
    }
  }
}
