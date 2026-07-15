import 'package:injectable/injectable.dart';
import '../../data/datasource/remote/models/negocio_model.dart';

abstract class NegocioRemoteDataSource {
  Future<List<NegocioModel>> obtenerNegocios({
    String? tipoNegocioId,
    String? busqueda,
    bool? soloVerificados,
    double? latitud,
    double? longitud,
  });

  Future<NegocioModel> obtenerNegocioPorId(String id);

  Future<List<NegocioModel>> buscarNegocios(String query);
}

// ─────────────────────────────────────────────────────────────────────────
// TODO: Cuando el endpoint esté listo, reemplazar por:
//
// @LazySingleton(as: NegocioRemoteDataSource)
// class NegocioRemoteDataSourceImpl implements NegocioRemoteDataSource {
//   final ApiClient _apiClient;
//   NegocioRemoteDataSourceImpl(this._apiClient);
//
//   @override
//   Future<List<NegocioModel>> obtenerNegocios({...}) async {
//     final response = await _apiClient.get(
//       AppConstants.negociosEndpoint,
//       queryParameters: {
//         if (tipoNegocioId != null) 'tipoNegocioId': tipoNegocioId,
//         if (busqueda != null) 'busqueda': busqueda,
//       },
//     );
//     final body = response.data as Map<String, dynamic>;
//     return (body['data'] as List)
//         .map((e) => NegocioModel.fromJson(e as Map<String, dynamic>))
//         .toList();
//   }
//   ...
// }
// ─────────────────────────────────────────────────────────────────────────

@LazySingleton(as: NegocioRemoteDataSource)
class NegocioRemoteDataSourceMock implements NegocioRemoteDataSource {
  // ── Catálogo ficticio ──────────────────────────────────────────────────
  static final List<Map<String, dynamic>> _negociosMock = [
    {
      'id': 'neg-001',
      'nombre': 'El Fogón de Jovel',
      'descripcion':
          'Restaurante de cocina de autor regional, con ingredientes '
          'locales y un ambiente cálido en el corazón de San Cristóbal.',
      'direccion': 'Real de Guadalupe 12, San Cristóbal de las Casas',
      'tipoNegocioId': 'restaurante',
      'tipoNegocioNombre': 'Restaurante',
      'latitud': 16.7370,
      'longitud': -92.6376,
      'precioDesde': 180.0,
      'calificacionPromedio': 4.7,
      'numeroResenas': 132,
      'verificado': true,
      'imagenPrincipal':
          'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800&q=80',
      'imagenes': [
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800&q=80',
        'https://images.unsplash.com/photo-1550966871-3ed3cdb5ed0c?w=800&q=80',
      ],
      'servicios': [
        {'id': 'srv-01', 'negocioId': 'neg-001', 'nombre': 'Wifi gratis'},
        {'id': 'srv-02', 'negocioId': 'neg-001', 'nombre': 'Terraza'},
        {'id': 'srv-03', 'negocioId': 'neg-001', 'nombre': 'Acepta tarjeta'},
      ],
      'horarios': [
        {
          'id': 'h-01',
          'negocioId': 'neg-001',
          'diaSemana': 'Lunes',
          'horaApertura': '12:00',
          'horaCierre': '22:00',
        },
        {
          'id': 'h-02',
          'negocioId': 'neg-001',
          'diaSemana': 'Martes',
          'horaApertura': '12:00',
          'horaCierre': '22:00',
        },
        {
          'id': 'h-03',
          'negocioId': 'neg-001',
          'diaSemana': 'Domingo',
          'cerrado': true,
        },
      ],
      'promocionesVigentes': ['2x1 en bebidas los martes'],
      'esFavorito': false,
    },
    {
      'id': 'neg-002',
      'nombre': 'Café Maya Luxury',
      'descripcion':
          'El mejor café de altura de San Cristóbal, tostado en casa.',
      'direccion': 'Av. Insurgentes 45, San Cristóbal de las Casas',
      'tipoNegocioId': 'restaurante',
      'tipoNegocioNombre': 'Restaurante',
      'latitud': 16.7380,
      'longitud': -92.6390,
      'precioDesde': 60.0,
      'calificacionPromedio': 4.9,
      'numeroResenas': 89,
      'verificado': true,
      'imagenPrincipal':
          'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800&q=80',
      'servicios': [
        {
          'id': 'srv-04',
          'negocioId': 'neg-002',
          'nombre': 'Café de especialidad',
        },
      ],
      'horarios': [
        {
          'id': 'h-04',
          'negocioId': 'neg-002',
          'diaSemana': 'Lunes',
          'horaApertura': '08:00',
          'horaCierre': '20:00',
        },
      ],
      'promocionesVigentes': [],
      'esFavorito': true,
    },
    {
      'id': 'neg-003',
      'nombre': 'Selva Verde Eco-Resort',
      'descripcion':
          'Resort ecológico rodeado de selva, con cabañas de madera y '
          'vistas al río. Ideal para desconectar.',
      'direccion': 'Carretera a Palenque km 8',
      'tipoNegocioId': 'hotel',
      'tipoNegocioNombre': 'Hotel',
      'latitud': 17.5090,
      'longitud': -91.9910,
      'precioDesde': 2400.0,
      'calificacionPromedio': 4.8,
      'numeroResenas': 210,
      'verificado': true,
      'imagenPrincipal':
          'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800&q=80',
      'imagenes': [
        'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800&q=80',
        'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80',
      ],
      'servicios': [
        {'id': 'srv-05', 'negocioId': 'neg-003', 'nombre': 'Alberca'},
        {'id': 'srv-06', 'negocioId': 'neg-003', 'nombre': 'Desayuno incluido'},
        {'id': 'srv-07', 'negocioId': 'neg-003', 'nombre': 'Estacionamiento'},
      ],
      'horarios': [
        {
          'id': 'h-05',
          'negocioId': 'neg-003',
          'diaSemana': 'Todos los días',
          'horaApertura': '00:00',
          'horaCierre': '23:59',
        },
      ],
      'promocionesVigentes': ['15% de descuento en estadías de 3+ noches'],
      'esFavorito': false,
    },
    {
      'id': 'neg-004',
      'nombre': 'Boutique Casa Lum',
      'descripcion': 'Hotel boutique en el centro histórico, diseño local.',
      'direccion': 'Calle Diego de Mazariegos 8',
      'tipoNegocioId': 'hotel',
      'tipoNegocioNombre': 'Hotel',
      'latitud': 16.7365,
      'longitud': -92.6400,
      'precioDesde': 3100.0,
      'calificacionPromedio': 4.6,
      'numeroResenas': 74,
      'verificado': false,
      'imagenPrincipal':
          'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80',
      'servicios': [
        {'id': 'srv-08', 'negocioId': 'neg-004', 'nombre': 'Spa'},
      ],
      'horarios': [],
      'promocionesVigentes': [],
      'esFavorito': false,
    },
    {
      'id': 'neg-005',
      'nombre': 'Tour Cañón del Sumidero',
      'descripcion':
          'Recorrido en lancha por el impresionante Cañón del Sumidero, '
          'con avistamiento de fauna local.',
      'direccion': 'Embarcadero Cahuaré, Tuxtla Gutiérrez',
      'tipoNegocioId': 'tour',
      'tipoNegocioNombre': 'Tour',
      'latitud': 16.7870,
      'longitud': -93.0450,
      'precioDesde': 350.0,
      'calificacionPromedio': 4.9,
      'numeroResenas': 305,
      'verificado': true,
      'imagenPrincipal':
          'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800&q=80',
      'servicios': [
        {'id': 'srv-09', 'negocioId': 'neg-005', 'nombre': 'Guía incluido'},
        {
          'id': 'srv-10',
          'negocioId': 'neg-005',
          'nombre': 'Chaleco salvavidas',
        },
      ],
      'horarios': [
        {
          'id': 'h-06',
          'negocioId': 'neg-005',
          'diaSemana': 'Todos los días',
          'horaApertura': '08:00',
          'horaCierre': '16:00',
        },
      ],
      'promocionesVigentes': [],
      'esFavorito': false,
    },
    {
      'id': 'neg-006',
      'nombre': 'Traslado San Cristóbal - Palenque',
      'descripcion': 'Servicio de transporte privado y cómodo entre destinos.',
      'direccion': 'Terminal de autobuses, San Cristóbal de las Casas',
      'tipoNegocioId': 'transporte',
      'tipoNegocioNombre': 'Transporte',
      'latitud': 16.7400,
      'longitud': -92.6350,
      'precioDesde': 450.0,
      'calificacionPromedio': 4.5,
      'numeroResenas': 58,
      'verificado': true,
      'imagenPrincipal':
          'https://images.unsplash.com/photo-1449965408869-eaa3f722e40d?w=800&q=80',
      'servicios': [
        {
          'id': 'srv-11',
          'negocioId': 'neg-006',
          'nombre': 'Aire acondicionado',
        },
      ],
      'horarios': [],
      'promocionesVigentes': [],
      'esFavorito': false,
    },
  ];

  @override
  Future<List<NegocioModel>> obtenerNegocios({
    String? tipoNegocioId,
    String? busqueda,
    bool? soloVerificados,
    double? latitud,
    double? longitud,
  }) async {
    // Simula latencia de red.
    await Future.delayed(const Duration(milliseconds: 600));

    var lista = _negociosMock;

    if (tipoNegocioId != null && tipoNegocioId.isNotEmpty) {
      lista = lista.where((n) => n['tipoNegocioId'] == tipoNegocioId).toList();
    }

    if (busqueda != null && busqueda.trim().isNotEmpty) {
      final q = busqueda.toLowerCase();
      lista = lista
          .where((n) => (n['nombre'] as String).toLowerCase().contains(q))
          .toList();
    }

    if (soloVerificados == true) {
      lista = lista.where((n) => n['verificado'] == true).toList();
    }

    return lista.map((json) => NegocioModel.fromJson(json)).toList();
  }

  @override
  Future<NegocioModel> obtenerNegocioPorId(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final json = _negociosMock.firstWhere(
      (n) => n['id'] == id,
      orElse: () => throw Exception('Negocio no encontrado: $id'),
    );

    return NegocioModel.fromJson(json);
  }

  @override
  Future<List<NegocioModel>> buscarNegocios(String query) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final q = query.toLowerCase();
    final lista = _negociosMock
        .where(
          (n) =>
              (n['nombre'] as String).toLowerCase().contains(q) ||
              (n['descripcion'] as String).toLowerCase().contains(q),
        )
        .toList();

    return lista.map((json) => NegocioModel.fromJson(json)).toList();
  }
}
