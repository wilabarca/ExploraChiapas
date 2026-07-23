/// Validaciones de formulario compartidas entre Login y Registro.
/// Centralizarlas evita reglas inconsistentes entre las dos pantallas.
class ValidadoresAuth {
  ValidadoresAuth._();

  static final RegExp _emailRegExp = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static const int telefonoDigitos = 10;

  static String? email(String value) {
    final texto = value.trim();
    if (texto.isEmpty) return 'Ingresa tu correo electrónico';
    if (!_emailRegExp.hasMatch(texto)) return 'Correo electrónico no válido';
    return null;
  }

  static String? password(String value, {int minLength = 6}) {
    if (value.isEmpty) return 'Ingresa tu contraseña';
    if (value.length < minLength) {
      return 'Debe tener al menos $minLength caracteres';
    }
    return null;
  }

  static String? confirmarPassword(String password, String confirmacion) {
    if (confirmacion.isEmpty) return 'Confirma tu contraseña';
    if (password != confirmacion) return 'Las contraseñas no coinciden';
    return null;
  }

  static String? nombre(String value) {
    final texto = value.trim();
    if (texto.isEmpty) return 'Ingresa tu nombre';
    if (texto.length < 2) return 'Ingresa un nombre válido';
    return null;
  }

  static String? telefono(String value) {
    final texto = value.trim();
    if (texto.isEmpty) return 'Ingresa tu teléfono';
    if (texto.length != telefonoDigitos) {
      return 'Debe tener $telefonoDigitos dígitos';
    }
    return null;
  }
}
