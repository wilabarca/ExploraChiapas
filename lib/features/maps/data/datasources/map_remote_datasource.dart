import '../models/destination_model.dart';

abstract class IMapRemoteDatasource {
  Future<List<DestinationModel>> getDestinations({String? tipo});
  Future<List<DestinationModel>> getDestinationsNearby({
    required double lat,
    required double lng,
    required double radioKm,
  });
  Future<List<List<double>>> getRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  });
}

class MapRemoteDatasourceImpl implements IMapRemoteDatasource {
  // Datos ficticios — reemplazar con llamada real al backend
  static const List<Map<String, dynamic>> _mockDestinations = [
    {
      'id': '1',
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
      'id': '2',
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
      'id': '3',
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
      'id': '4',
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
      'id': '5',
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
      'id': '6',
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
      'id': '7',
      'nombre': 'Cascada El Chiflón',
      'tipo': 'aventura',
      'descripcion': 'Cascada de 120 m ideal para tirolesa y senderismo.',
      'lat': 15.9667,
      'lng': -92.2833,
      'calificacion': 4.7,
      'afluencia': 40,
      'es_sostenible': true,
    },
  ];

  // Ruta ficticia entre dos puntos (simulación de polyline)
  static const List<List<double>> _mockRoute = [
    [16.7370, -92.6376],
    [16.7800, -92.7000],
    [16.8200, -92.8500],
    [16.8560, -93.0760],
  ];

  @override
  Future<List<DestinationModel>> getDestinations({String? tipo}) async {
    await Future.delayed(const Duration(milliseconds: 600)); // simula red
    final data = tipo == null
        ? _mockDestinations
        : _mockDestinations.where((d) => d['tipo'] == tipo).toList();
    return data.map(DestinationModel.fromJson).toList();
  }

  @override
  Future<List<DestinationModel>> getDestinationsNearby({
    required double lat,
    required double lng,
    required double radioKm,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Mock: devuelve todos (el filtro real va en backend)
    return _mockDestinations.map(DestinationModel.fromJson).toList();
  }

  @override
  Future<List<List<double>>> getRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    return _mockRoute;
  }
}