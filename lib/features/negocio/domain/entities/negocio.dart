import 'negocio_horario.dart';
import 'negocio_servicio.dart';

class Negocio {
  final String id;
  final String nombre;
  final String descripcion;
  final String direccion;
  final String tipoNegocioId;
  final String tipoNegocioNombre;

  /// Id real de ubicación (`locationId` del backend). La API de negocios
  /// no devuelve lat/lng ni dirección directamente en `/businesses` — hay
  /// que resolverlos vía `GET /locations/{locationId}`, igual que con
  /// destinos.
  final String? locationId;
  final double latitud;
  final double longitud;
  final double? precioDesde;
  final double calificacionPromedio;
  final int numeroResenas;
  final bool verificado;
  final String imagenPrincipal;
  final List<String> imagenes;
  final List<NegocioServicio> servicios;
  final List<NegocioHorario> horarios;
  final List<String> promocionesVigentes;
  final bool esFavorito;

  const Negocio({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.direccion,
    required this.tipoNegocioId,
    required this.tipoNegocioNombre,
    this.locationId,
    required this.latitud,
    required this.longitud,
    this.precioDesde,
    required this.calificacionPromedio,
    required this.numeroResenas,
    this.verificado = false,
    required this.imagenPrincipal,
    this.imagenes = const [],
    this.servicios = const [],
    this.horarios = const [],
    this.promocionesVigentes = const [],
    this.esFavorito = false,
  });

  bool get tieneCoordenadasValidas =>
      latitud >= -90 &&
      latitud <= 90 &&
      longitud >= -180 &&
      longitud <= 180 &&
      !(latitud == 0 && longitud == 0);
}
