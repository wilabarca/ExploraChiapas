import '../../../../domain/entities/negocio_horario.dart';

class NegocioHorarioModel extends NegocioHorario {
  const NegocioHorarioModel({
    required super.id,
    required super.negocioId,
    required super.diaSemana,
    super.horaApertura,
    super.horaCierre,
    super.cerrado,
  });

  factory NegocioHorarioModel.fromJson(Map<String, dynamic> json) {
    return NegocioHorarioModel(
      id: json['id'] as String,
      negocioId: json['negocioId'] as String,
      diaSemana: json['diaSemana'] as String,
      horaApertura: json['horaApertura'] as String?,
      horaCierre: json['horaCierre'] as String?,
      cerrado: json['cerrado'] as bool? ?? false,
    );
  }
}
