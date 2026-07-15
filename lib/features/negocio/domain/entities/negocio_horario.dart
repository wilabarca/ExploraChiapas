class NegocioHorario {
  final String id;
  final String negocioId;
  final String diaSemana; // 'Lunes', 'Martes', ...
  final String? horaApertura; // '09:00'
  final String? horaCierre;   // '18:00'
  final bool cerrado;

  const NegocioHorario({
    required this.id,
    required this.negocioId,
    required this.diaSemana,
    this.horaApertura,
    this.horaCierre,
    this.cerrado = false,
  });
}