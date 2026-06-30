class ActividadEntity {
  final int id;
  final String nombre;
  final String tipo;
  final String municipio;
  final String? categoria;
  final String? tipoComida;
  final double costoEstimado;
  final double costoTotalGrupo;
  final double tiempoHoras;
  final int nivelAfluencia;
  final String? clusterAfluencia;

  const ActividadEntity({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.municipio,
    this.categoria,
    this.tipoComida,
    required this.costoEstimado,
    required this.costoTotalGrupo,
    required this.tiempoHoras,
    required this.nivelAfluencia,
    this.clusterAfluencia,
  });

  bool get esDestino => tipo == 'destino';
  bool get esRestaurante => tipo == 'restaurante';
}
