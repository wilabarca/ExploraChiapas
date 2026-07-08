import '../../../core/di/injector.dart';
import '../../../core/network/api_client.dart';

class PromocionItem {
  final String id;
  final String titulo;
  final String? descripcion;
  final double? precio;
  final String? negocioNombre;

  PromocionItem({
    required this.id,
    required this.titulo,
    this.descripcion,
    this.precio,
    this.negocioNombre,
  });

  factory PromocionItem.fromJson(Map<String, dynamic> json) {
    return PromocionItem(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String?,
      precio: (json['precio'] as num?)?.toDouble(),
      negocioNombre: json['negocioNombre'] as String?,
    );
  }
}

class EventoItem {
  final String id;
  final String titulo;
  final String? descripcion;
  final String fechaInicio;
  final String? municipio;

  EventoItem({
    required this.id,
    required this.titulo,
    this.descripcion,
    required this.fechaInicio,
    this.municipio,
  });

  factory EventoItem.fromJson(Map<String, dynamic> json) {
    final rawFecha = json['fechaInicio'] as String? ?? '';
    final fecha = rawFecha.length >= 10 ? rawFecha.substring(0, 10) : rawFecha;
    return EventoItem(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String?,
      fechaInicio: fecha,
      municipio: json['municipio'] as String?,
    );
  }
}

class HomeApiService {
  final ApiClient _api = getIt<ApiClient>();

  Future<List<PromocionItem>> fetchPromociones() async {
    final response = await _api.get('/promotions');
    final data = response.data['data'] as List<dynamic>;
    return data
        .map((e) => PromocionItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<EventoItem>> fetchEventos() async {
    final response = await _api.get(
      '/events',
      queryParameters: {'proximas': 'true'},
    );
    final data = response.data['data'] as List<dynamic>;
    return data
        .map((e) => EventoItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
