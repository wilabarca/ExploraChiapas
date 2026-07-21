class Categoria {
  final String id;
  final String nombre;
  final String icono;
  final bool aplicaAEventos;
  final bool aplicaADestinos;

  const Categoria({
    required this.id,
    required this.nombre,
    required this.icono,
    required this.aplicaAEventos,
    required this.aplicaADestinos,
  });
}
