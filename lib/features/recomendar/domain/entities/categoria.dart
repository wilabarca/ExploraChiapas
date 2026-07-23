class Categoria {
  final String id;
  final String nombre;
  final String? icono;

  const Categoria({
    required this.id,
    required this.nombre,
    this.icono,
  });
}
