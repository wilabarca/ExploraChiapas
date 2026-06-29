import '../../domain/entities/recomendacion_entity.dart';
import 'actividad_model.dart';

class RecomendacionModel extends RecomendacionEntity {
  const RecomendacionModel({
    required super.mensaje,
    required super.itinerario,
    required super.costoTotal,
    required super.tiempoTotalHoras,
    required super.reglasAsociacionAplicadas,
  });

  // El endpoint POST /planear de la Capa 1 devuelve
  // { parametros, recomendacion: { itinerario, costo_total, ... }, mensaje }.
  factory RecomendacionModel.fromJson(Map<String, dynamic> json) {
    final recomendacion = json['recomendacion'] as Map<String, dynamic>;
    final itinerarioJson = recomendacion['itinerario'] as List<dynamic>;
    final reglasJson =
        recomendacion['reglas_asociacion_aplicadas'] as List<dynamic>? ?? [];

    return RecomendacionModel(
      mensaje:          json['mensaje'] as String,
      itinerario:       itinerarioJson
          .map((item) => ActividadModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      costoTotal:       (recomendacion['costo_total'] as num).toDouble(),
      tiempoTotalHoras: (recomendacion['tiempo_total_horas'] as num).toDouble(),
      reglasAsociacionAplicadas: reglasJson.cast<String>(),
    );
  }
}
