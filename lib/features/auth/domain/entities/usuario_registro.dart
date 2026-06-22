enum TipoUsuario { turista, local }

class UsuarioRegistro {
  final String nombre;
  final String correo;
  final String contrasena;
  final String telefono;
  final TipoUsuario tipoUsuario;

  const UsuarioRegistro({
    required this.nombre,
    required this.correo,
    required this.contrasena,
    required this.telefono,
    required this.tipoUsuario,
  });
} // TURISTA | LOCAL
