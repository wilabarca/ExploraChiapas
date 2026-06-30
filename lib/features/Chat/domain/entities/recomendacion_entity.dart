import 'actividad_entity.dart';

class RecomendacionEntity {
  final String mensaje;
  final List<ActividadEntity> itinerario;
  final double costoTotal;
  final double tiempoTotalHoras;
  final List<String> reglasAsociacionAplicadas;

  const RecomendacionEntity({
    required this.mensaje,
    required this.itinerario,
    required this.costoTotal,
    required this.tiempoTotalHoras,
    required this.reglasAsociacionAplicadas,
  });
}
