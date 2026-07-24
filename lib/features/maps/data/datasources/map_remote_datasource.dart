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

  @override
  Future<List<DestinationModel>> getDestinations({String? tipo}) async {
    try {
      final response = await _apiClient.get(AppConstants.destinationsEndpoint);
      final raw = response.data['data'] as List<dynamic>;
      if (raw.isEmpty) throw Exception('backend_empty');
      final all = raw
          .map((e) => DestinationModel.fromJson(e as Map<String, dynamic>))
          .toList();
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
  }) async {
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
      if (e.type == DioExceptionType.connectionError) {
        // Sin internet: devuelve estimación Haversine para poder mostrar algo.
        return [_fallbackHaversine(originLat, originLng, destLat, destLng)];
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return [_fallbackHaversine(originLat, originLng, destLat, destLng)];
      }
      throw Exception('No se pudo calcular la ruta. Intenta de nuevo.');
    }

    final body = response.data;
    final routes = body?['routes'] as List<dynamic>?;
    if (routes == null || routes.isEmpty) {
      throw Exception(
        'No se encontró una ruta hacia ese destino por carretera.',
      );
    }

    return routes.map((route) {
      final coords =
          (route['geometry']['coordinates'] as List<dynamic>).cast<List<dynamic>>();
      final points = coords
          .map((c) => [(c[1] as num).toDouble(), (c[0] as num).toDouble()])
          .toList();

      final rawMeters = (route['distance'] as num?)?.toDouble() ?? 0.0;
      final rawSeconds = (route['duration'] as num?)?.toDouble() ?? 0.0;
      final distanceKm = (rawMeters / 1000 * 10).round() / 10.0;

      // Modelo de corrección diferenciado por zona (ver README de rutas):
      //   < 20 km  → 1.2x  urbano (Tuxtla / San Cristóbal)
      //   20–80 km → 1.4x  semi-rural (conexiones entre cabeceras)
      //   > 80 km  → 1.6x  rural/montaña (Palenque, Montebello, El Chiflón)
      final factor = _factorCorreccion(rawMeters);
      final durationMinutes = (rawSeconds * factor / 60).round();

      return RouteInfo(
        points: points,
        durationMinutes: durationMinutes,
        distanceKm: distanceKm,
      );
    }).toList();
  }

  // Factor diferenciado: OSRM usa velocidades teóricas de OSM que no reflejan
  // la realidad de Chiapas (topes, curvas de montaña, caminos de terracería).
  static double _factorCorreccion(double metros) {
    final km = metros / 1000;
    if (km < 20) return 1.2;
    if (km < 80) return 1.4;
    return 1.6;
  }

  // Estimación de respaldo cuando OSRM no está disponible.
  // Haversine da línea recta; multiplicamos por 1.35 (tortuosidad típica de
  // carreteras en sierra) y asumimos 35 km/h promedio (urbano+rural).
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
    final distanciaKm = (distanciaMetros / 1000 * 10).round() / 10.0;
    final durationMinutes = (distanciaMetros / (35000 / 60)).round();

    // Sin OSRM no tenemos polilínea real — devolvemos solo origen y destino
    // para que el mapa dibuje una línea recta indicativa.
    final points = [[lat1, lng1], [lat2, lng2]];
    return RouteInfo(
      points: points,
      durationMinutes: durationMinutes,
      distanceKm: distanciaKm,
    );
  }
}