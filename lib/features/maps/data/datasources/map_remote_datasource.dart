import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/app_constants.dart';
import 'remote/models/destination_model.dart';

abstract class IMapRemoteDatasource {
  Future<List<DestinationModel>> getDestinations({String? tipo});
  Future<List<DestinationModel>> getDestinationsNearby({
    required double lat,
    required double lng,
    required double radioKm,
  });
  Future<List<List<List<double>>>> getRoutes({
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
  Future<List<List<List<double>>>> getRoutes({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    final dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 10)));

    final response = await dio.get<Map<String, dynamic>>(
      'https://router.project-osrm.org/route/v1/driving/'
      '$originLng,$originLat;$destLng,$destLat',
      queryParameters: {
        'overview': 'full',
        'geometries': 'geojson',
        'alternatives': 'true',
      },
    );

    final routes = response.data!['routes'] as List<dynamic>;
    if (routes.isEmpty) throw Exception('No se encontró ruta');

    return routes.map((route) {
      final coords =
          (route['geometry']['coordinates'] as List<dynamic>).cast<List<dynamic>>();
      return coords
          .map((c) => [(c[1] as num).toDouble(), (c[0] as num).toDouble()])
          .toList();
    }).toList();
  }
}