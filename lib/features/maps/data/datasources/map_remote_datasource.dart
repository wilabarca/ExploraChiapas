import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/app_constants.dart';
import '../../domain/entities/route_info.dart';
import 'remote/models/destination_model.dart';

abstract class IMapRemoteDatasource {
  Future<List<DestinationModel>> getDestinations({String? tipo});
  Future<List<DestinationModel>> getDestinationsNearby({
    required double lat,
    required double lng,
    required double radioKm,
  });
  Future<List<RouteInfo>> getRoutes({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    String perfil = 'driving',
  });
}

class MapRemoteDatasourceImpl implements IMapRemoteDatasource {
  final ApiClient _apiClient;

  MapRemoteDatasourceImpl(this._apiClient);

  static const List<Map<String, dynamic>> _mockDestinations = [
    {
      'id': 'a1b2c3d4-e5f6-4a7b-8c9d-000000000001',
      'nombre': 'Cañón del Sumidero',
      'tipo': 'naturaleza',
      'descripcion': 'Impresionante cañón con paredes de hasta 1,000 m.',
      'lat': 16.8560,
      'lng': -93.0760,
      'calificacion': 4.8,
      'afluencia': 85,
      'es_sostenible': false,
    },
    {
      'id': 'a1b2c3d4-e5f6-4a7b-8c9d-000000000002',
      'nombre': 'San Cristóbal de las Casas',
      'tipo': 'cultura',
      'descripcion': 'Ciudad colonial con mercados y arquitectura colonial.',
      'lat': 16.7370,
      'lng': -92.6376,
      'calificacion': 4.7,
      'afluencia': 90,
      'es_sostenible': false,
    },
    {
      'id': 'a1b2c3d4-e5f6-4a7b-8c9d-000000000003',
      'nombre': 'Lagunas de Montebello',
      'tipo': 'naturaleza',
      'descripcion': 'Sistema de lagunas de colores únicos en la frontera.',
      'lat': 16.1167,
      'lng': -91.6833,
      'calificacion': 4.6,
      'afluencia': 45,
      'es_sostenible': true,
    },
    {
      'id': 'a1b2c3d4-e5f6-4a7b-8c9d-000000000004',
      'nombre': 'Palenque',
      'tipo': 'cultura',
      'descripcion': 'Zona arqueológica maya rodeada de selva tropical.',
      'lat': 17.4838,
      'lng': -92.0435,
      'calificacion': 4.9,
      'afluencia': 78,
      'es_sostenible': false,
    },
    {
      'id': 'a1b2c3d4-e5f6-4a7b-8c9d-000000000005',
      'nombre': 'Cascadas de Agua Azul',
      'tipo': 'naturaleza',
      'descripcion': 'Cascadas turquesas en medio de la selva chiapaneca.',
      'lat': 17.2524,
      'lng': -92.1131,
      'calificacion': 4.5,
      'afluencia': 60,
      'es_sostenible': true,
    },
    {
      'id': 'a1b2c3d4-e5f6-4a7b-8c9d-000000000006',
      'nombre': 'Restaurante La Galería',
      'tipo': 'gastronomia',
      'descripcion': 'Cocina chiapaneca tradicional en el centro histórico.',
      'lat': 16.7360,
      'lng': -92.6350,
      'calificacion': 4.4,
      'afluencia': 30,
      'es_sostenible': true,
    },
    {
      'id': 'a1b2c3d4-e5f6-4a7b-8c9d-000000000007',
      'nombre': 'Cascada El Chiflón',
      'tipo': 'aventura',
      'descripcion': 'Cascada de 120 m ideal para tirolesa y senderismo.',
      'lat': 15.9667,
      'lng': -92.2833,
      'calificacion': 4.7,
      'afluencia': 40,
      'es_sostenible': true,
    },
    {
      'id': 'a1b2c3d4-e5f6-4a7b-8c9d-000000000008',
      'nombre': 'Hotel Parador San Juan de Dios',
      'tipo': 'descanso',
      'descripcion': 'Hotel boutique en el corazón de San Cristóbal.',
      'lat': 16.7368,
      'lng': -92.6385,
      'calificacion': 4.5,
      'afluencia': 25,
      'es_sostenible': true,
    },
    {
      'id': 'a1b2c3d4-e5f6-4a7b-8c9d-000000000009',
      'nombre': 'Spa Cañón del Sumidero',
      'tipo': 'descanso',
      'descripcion': 'Spa con vista al cañón, masajes y terapias naturales.',
      'lat': 16.8540,
      'lng': -93.0720,
      'calificacion': 4.3,
      'afluencia': 20,
      'es_sostenible': true,
    },
  ];

  // El endpoint real `/destinations` NO devuelve `nombre`/`tipo`/`lat`/`lng`
  // como asumía la versión anterior de este datasource (esos nombres de
  // campo eran de un mock inventado) — devuelve `name`, `categoryId` y
  // `locationId` (coordenadas en un recurso aparte, `/locations/{id}`,
  // igual que ya se resolvió para negocios). Como consecuencia, este mapa
  // SIEMPRE caía al fallback mock, incluso con backend sano: cada llamada
  // lanzaba una excepción de cast al intentar leer campos que no existían.
  //
  // Ahora se piden en paralelo destinos + `/locations` (para lat/lng real
  // vía `locationId`) + `/categories` (para traducir `categoryId` al slug
  // de tipo — naturaleza/cultura/etc. — que ya usan los íconos y colores
  // del mapa). Un destino sin ubicación resoluble simplemente se omite en
  // vez de inventarle coordenadas.
  @override
  Future<List<DestinationModel>> getDestinations({String? tipo}) async {
    try {
      final resultados = await Future.wait([
        _apiClient.get(AppConstants.destinationsEndpoint),
        _apiClient.get(AppConstants.locationsEndpoint),
        // `scope: 'destinos'` es obligatorio aquí: sin él, `/categories`
        // devuelve solo las categorías marcadas para EVENTOS (p. ej.
        // "Festivales"/"Talleres") y omite las de destinos reales como
        // "Pueblos Mágicos" o "Arqueología" — por eso esos destinos
        // caían siempre en el `tipo: 'otro'` genérico (ícono/color de
        // "sin categoría") aunque sí tuvieran una categoría real asignada.
        _apiClient.get(
          AppConstants.categoriesEndpoint,
          queryParameters: {'scope': 'destinos'},
        ),
      ]);

      final rawDestinos = resultados[0].data['data'] as List<dynamic>;
      final rawLocations = resultados[1].data['data'] as List<dynamic>;
      final rawCategorias = resultados[2].data['data'] as List<dynamic>;

      if (rawDestinos.isEmpty) throw Exception('backend_empty');

      final coordsPorLocationId = <String, (double, double)>{
        for (final loc in rawLocations.cast<Map<String, dynamic>>())
          if (loc['id'] != null &&
              loc['latitude'] != null &&
              loc['longitude'] != null)
            loc['id'] as String: (
              (loc['latitude'] as num).toDouble(),
              (loc['longitude'] as num).toDouble(),
            ),
      };

      final slugPorCategoryId = <String, String>{
        for (final cat in rawCategorias.cast<Map<String, dynamic>>())
          if (cat['id'] != null)
            cat['id'] as String: _slugCategoria(cat['nombre'] as String? ?? ''),
      };

      final all = <DestinationModel>[];
      for (final e in rawDestinos.cast<Map<String, dynamic>>()) {
        final locationId = e['locationId'] as String?;
        final coords = coordsPorLocationId[locationId];
        if (coords == null) continue; // sin ubicación real, se omite

        final isSaturated = e['isSaturated'] as bool? ?? false;
        all.add(
          DestinationModel(
            id: e['id'] as String,
            nombre: e['name'] as String? ?? '',
            tipo: slugPorCategoryId[e['categoryId']] ?? 'otro',
            descripcion: e['description'] as String? ?? '',
            lat: coords.$1,
            lng: coords.$2,
            calificacion: (e['averageRating'] as num?)?.toDouble() ?? 0,
            // El backend solo da `isSaturated` (bool), no un porcentaje de
            // afluencia — se traduce al umbral que ya usa la UI (>75 =
            // "alta") en vez de inventar un número específico.
            afluencia: isSaturated ? 90 : 30,
            esSostenible: !isSaturated,
            categoryId: e['categoryId'] as String?,
          ),
        );
      }

      if (tipo != null) {
        final filtered = all
            .where((d) => d.tipo.toLowerCase() == tipo.toLowerCase())
            .toList();
        if (filtered.isEmpty) throw Exception('no_match');
        return filtered;
      }
      return all;
    } catch (e, st) {
      debugPrint(
        '[MapRemoteDatasource] getDestinations($tipo) falló, usando mock: $e',
      );
      debugPrintStack(stackTrace: st);
      await Future.delayed(const Duration(milliseconds: 300));
      final data = tipo == null
          ? _mockDestinations
          : _mockDestinations.where((d) => d['tipo'] == tipo).toList();
      return data
          .map((json) => DestinationModel.fromJson(json, esMock: true))
          .toList();
    }
  }

  static String _slugCategoria(String nombre) {
    const acentos = {
      'á': 'a',
      'é': 'e',
      'í': 'i',
      'ó': 'o',
      'ú': 'u',
      'ñ': 'n',
    };
    var slug = nombre.toLowerCase();
    acentos.forEach((con, sin) => slug = slug.replaceAll(con, sin));
    return slug.trim();
  }

  @override
  Future<List<DestinationModel>> getDestinationsNearby({
    required double lat,
    required double lng,
    required double radioKm,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockDestinations
        .map((json) => DestinationModel.fromJson(json, esMock: true))
        .toList();
  }

  @override
  Future<List<RouteInfo>> getRoutes({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    String perfil = 'driving',
  }) async {
    // Driving → OSRM (rápido, rutas de carretera buenas para México)
    // Foot/bike → Valhalla (maneja mejor datos OSM incompletos en Chiapas)
    if (perfil == 'driving') {
      return _rutasOsrm(originLat, originLng, destLat, destLng);
    } else {
      final costingValhalla = perfil == 'foot' ? 'pedestrian' : 'bicycle';
      return _rutaValhalla(originLat, originLng, destLat, destLng, costingValhalla);
    }
  }

  Future<List<RouteInfo>> _rutasOsrm(
    double originLat, double originLng,
    double destLat, double destLng,
  ) async {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    Response<Map<String, dynamic>> response;
    try {
      response = await dio.get<Map<String, dynamic>>(
        'https://router.project-osrm.org/route/v1/driving/'
        '$originLng,$originLat;$destLng,$destLat',
        queryParameters: {
          'overview': 'full',
          'geometries': 'geojson',
          'alternatives': '2',
        },
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return [_fallbackHaversine(originLat, originLng, destLat, destLng)];
      }
      throw Exception('No se pudo calcular la ruta. Intenta de nuevo.');
    }

    final routes = response.data?['routes'] as List<dynamic>?;
    if (routes == null || routes.isEmpty) {
      throw Exception('No se encontró una ruta hacia ese destino por carretera.');
    }

    return routes.map((route) {
      final coords = (route['geometry']['coordinates'] as List<dynamic>)
          .cast<List<dynamic>>();
      final points = coords
          .map((c) => [(c[1] as num).toDouble(), (c[0] as num).toDouble()])
          .toList();
      final rawMeters = (route['distance'] as num?)?.toDouble() ?? 0.0;
      final rawSeconds = (route['duration'] as num?)?.toDouble() ?? 0.0;
      return RouteInfo(
        points: points,
        distanceMeters: rawMeters,
        durationSeconds: rawSeconds * _factorCorreccion(rawMeters),
      );
    }).toList();
  }

  // Valhalla maneja redes OSM incompletas con modelos de costo, lo que da
  // mejores tiempos peatonales/ciclistas que OSRM en zonas rurales de Chiapas.
  Future<List<RouteInfo>> _rutaValhalla(
    double originLat, double originLng,
    double destLat, double destLng,
    String costing,
  ) async {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 12),
        receiveTimeout: const Duration(seconds: 12),
      ),
    );

    try {
      final response = await dio.get<Map<String, dynamic>>(
        'https://valhalla.openstreetmap.de/route',
        queryParameters: {
          'json': '{"locations":[{"lon":$originLng,"lat":$originLat},'
              '{"lon":$destLng,"lat":$destLat}],'
              '"costing":"$costing",'
              '"shape_format":"geojson"}',
        },
      );

      final trip = response.data?['trip'] as Map<String, dynamic>?;
      final summary = trip?['summary'] as Map<String, dynamic>?;
      final legs = trip?['legs'] as List<dynamic>?;
      if (summary == null || legs == null || legs.isEmpty) {
        return [_fallbackHaversine(originLat, originLng, destLat, destLng)];
      }

      final distMeters = ((summary['length'] as num?)?.toDouble() ?? 0.0) * 1000;
      final durSeconds = (summary['time'] as num?)?.toDouble() ?? 0.0;

      // Extraer polilínea del primer leg
      final shape = (legs[0] as Map<String, dynamic>)['shape'];
      List<List<double>> points;
      if (shape is Map) {
        // GeoJSON LineString
        final coords = (shape['coordinates'] as List<dynamic>).cast<List<dynamic>>();
        points = coords
            .map((c) => [(c[1] as num).toDouble(), (c[0] as num).toDouble()])
            .toList();
      } else {
        points = [[originLat, originLng], [destLat, destLng]];
      }

      return [RouteInfo(points: points, distanceMeters: distMeters, durationSeconds: durSeconds)];
    } on DioException {
      // Si Valhalla falla, vuelve a estimación desde distancia
      return [_fallbackHaversine(originLat, originLng, destLat, destLng)];
    }
  }

  // < 20 km → 1.2x urbano, 20–80 km → 1.4x semi-rural, > 80 km → 1.6x montaña
  static double _factorCorreccion(double metros) {
    final km = metros / 1000;
    if (km < 20) return 1.2;
    if (km < 80) return 1.4;
    return 1.6;
  }

  // Respaldo cuando OSRM no está disponible: Haversine × 1.35 tortuosidad,
  // 35 km/h promedio, polilínea de dos puntos (línea recta indicativa).
  static RouteInfo _fallbackHaversine(
    double lat1, double lng1,
    double lat2, double lng2,
  ) {
    const r = 6371000.0;
    final dLat = (lat2 - lat1) * math.pi / 180;
    final dLng = (lng2 - lng1) * math.pi / 180;
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) *
            math.cos(lat2 * math.pi / 180) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final lineaRecta = r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final distanciaMetros = lineaRecta * 1.35;
    return RouteInfo(
      points: [[lat1, lng1], [lat2, lng2]],
      distanceMeters: distanciaMetros,
      durationSeconds: distanciaMetros / (35000 / 3600),
    );
  }
}
