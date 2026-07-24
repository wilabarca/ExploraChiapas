import 'package:dio/dio.dart';
import '../../domain/entities/via_poi_entity.dart';

/// Casetas de cobro y gasolineras reales a lo largo de las carreteras,
/// obtenidas de Overpass API (OpenStreetMap) — la misma fuente de datos
/// reales ya usada en la app para ruteo (OSRM) y geocodificación
/// (Nominatim). No hay endpoint propio del backend para esto, así que se
/// consulta directo a Overpass, acotado al recuadro visible del mapa.
class OverpassViasDatasource {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://overpass-api.de',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  Future<List<ViaPoiEntity>> obtenerPois({
    required double south,
    required double west,
    required double north,
    required double east,
  }) async {
    final query =
        '[out:json][timeout:15];'
        '('
        'node["barrier"="toll_booth"]($south,$west,$north,$east);'
        'node["amenity"="fuel"]($south,$west,$north,$east);'
        ');'
        'out body 300;';

    try {
      final response = await _dio.post(
        '/api/interpreter',
        data: {'data': query},
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          responseType: ResponseType.json,
        ),
      );

      final elementos = (response.data['elements'] as List?) ?? [];
      return elementos
          .map((e) => _mapearElemento(e as Map<String, dynamic>))
          .whereType<ViaPoiEntity>()
          .toList();
    } catch (_) {
      // Overpass caído o sin conexión: simplemente no se muestra la capa,
      // sin romper el resto del mapa.
      return [];
    }
  }

  ViaPoiEntity? _mapearElemento(Map<String, dynamic> e) {
    final tags = (e['tags'] as Map?)?.cast<String, dynamic>() ?? {};
    final lat = (e['lat'] as num?)?.toDouble();
    final lng = (e['lon'] as num?)?.toDouble();
    final id = (e['id'] as num?)?.toInt();
    if (lat == null || lng == null || id == null) return null;

    final TipoViaPoi tipo;
    if (tags['barrier'] == 'toll_booth') {
      tipo = TipoViaPoi.casetaCobro;
    } else if (tags['amenity'] == 'fuel') {
      tipo = TipoViaPoi.gasolinera;
    } else {
      return null;
    }

    final nombre =
        (tags['name'] as String?) ??
        (tipo == TipoViaPoi.casetaCobro ? 'Caseta de cobro' : 'Gasolinera');

    return ViaPoiEntity(id: id, lat: lat, lng: lng, nombre: nombre, tipo: tipo);
  }
}
