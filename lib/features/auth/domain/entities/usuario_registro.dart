enum TipoUsuario { turistaNacional, turistaExtranjero, habitanteLocal }

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

  bool get esTurista =>
      tipoUsuario == TipoUsuario.turistaNacional ||
      tipoUsuario == TipoUsuario.turistaExtranjero;

  bool get esLocal => tipoUsuario == TipoUsuario.habitanteLocal;

  String get userTypeId {
    switch (tipoUsuario) {
      case TipoUsuario.turistaNacional:
        return 'turista_nacional';
      case TipoUsuario.turistaExtranjero:
        return 'turista_extranjero';
      case TipoUsuario.habitanteLocal:
        return 'habitante_local';
    }
  }
}
