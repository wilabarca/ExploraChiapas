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

  static const _diasSemana = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];

  /// El backend real (`schedules` en `GET /businesses/{id}`) usa
  /// `businessId`, `dayOfWeek` (1=lunes..7=domingo), `openingTime`/
  /// `closingTime` ("HH:mm:ss") y `closed` — nombres de campo distintos
  /// a los que asumía este mapper originalmente (`negocioId`,
  /// `diaSemana`, `horaApertura`/`horaCierre`, `cerrado`), lo que
  /// causaba un crash de tipo al abrir el detalle de un negocio real.
  /// Se soportan ambos formatos sin tocar la entidad de dominio.
  factory NegocioHorarioModel.fromJson(Map<String, dynamic> json) {
    final negocioId =
        (json['businessId'] ?? json['negocioId'])?.toString() ?? '';

    String diaSemana;
    final dayOfWeek = json['dayOfWeek'];
    if (dayOfWeek is num && dayOfWeek >= 1 && dayOfWeek <= 7) {
      diaSemana = _diasSemana[dayOfWeek.toInt() - 1];
    } else {
      diaSemana = (json['diaSemana'] ?? '').toString();
    }

    return NegocioHorarioModel(
      id: json['id']?.toString() ?? '',
      negocioId: negocioId,
      diaSemana: diaSemana,
      horaApertura: _formatearHora(json['openingTime'] ?? json['horaApertura']),
      horaCierre: _formatearHora(json['closingTime'] ?? json['horaCierre']),
      cerrado: (json['closed'] ?? json['cerrado']) as bool? ?? false,
    );
  }

  /// "08:00:00" (formato del backend) → "08:00" (formato de UI).
  static String? _formatearHora(dynamic value) {
    final texto = value?.toString();
    if (texto == null || texto.isEmpty) return null;
    final partes = texto.split(':');
    if (partes.length >= 2) return '${partes[0]}:${partes[1]}';
    return texto;
  }
}
