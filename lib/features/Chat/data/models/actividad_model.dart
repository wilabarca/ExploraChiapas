import '../../domain/entities/actividad_entity.dart';

class ActividadModel extends ActividadEntity {
  const ActividadModel({
    required super.id,
    required super.nombre,
    required super.tipo,
    required super.municipio,
    super.categoria,
    super.tipoComida,
    required super.costoEstimado,
    required super.costoTotalGrupo,
    required super.tiempoHoras,
    required super.nivelAfluencia,
    super.clusterAfluencia,
  });

  factory ActividadModel.fromJson(Map<String, dynamic> json) {
    return ActividadModel(
      id:               json['id'] as int,
      nombre:           json['nombre'] as String,
      tipo:             json['tipo'] as String,
      municipio:        json['municipio'] as String,
      categoria:        json['categoria'] as String?,
      tipoComida:       json['tipo_comida'] as String?,
      costoEstimado:    (json['costo_estimado'] as num).toDouble(),
      costoTotalGrupo:  (json['costo_total_grupo'] as num).toDouble(),
      tiempoHoras:      (json['tiempo_horas'] as num).toDouble(),
      nivelAfluencia:   json['nivel_afluencia'] as int,
      clusterAfluencia: json['cluster_afluencia'] as String?,
    );
  }
}
