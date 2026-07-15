import 'negocio_horario.dart';
import 'negocio_servicio.dart';

class Negocio {
  final String id;
  final String nombre;
  final String descripcion;
  final String direccion;
  final String tipoNegocioId;
  final String tipoNegocioNombre;
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
}