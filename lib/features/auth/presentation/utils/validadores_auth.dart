/// Validaciones de formulario compartidas entre Login y Registro.
/// Centralizarlas evita reglas inconsistentes entre las dos pantallas.
class ValidadoresAuth {
  ValidadoresAuth._();

  static final RegExp _emailRegExp = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final RegExp _soloDigitos = RegExp(r'^[0-9]+$');
  static final RegExp _tieneMinuscula = RegExp(r'[a-z]');
  static final RegExp _tieneMayuscula = RegExp(r'[A-Z]');
  static final RegExp _tieneNumero = RegExp(r'[0-9]');

  static const int emailMaxLength = 150;
  static const int nombreMinLength = 2;
  static const int nombreMaxLength = 100;
  static const int telefonoMinDigitos = 10;
  static const int telefonoMaxDigitos = 15;
  static const int passwordMinLength = 8;
  static const int passwordMaxLength = 72;

  static String? email(String value) {
    final texto = value.trim();
    if (texto.isEmpty) return 'Ingresa tu correo electrónico';
    if (texto.length > emailMaxLength) {
      return 'El correo no puede superar los $emailMaxLength caracteres';
    }
    if (!_emailRegExp.hasMatch(texto)) return 'Correo electrónico no válido';
    return null;
  }

  /// [minLength] se conserva como parámetro (compatibilidad con quien ya
  /// lo llamaba pasando su propio mínimo), pero nunca debe bajar de
  /// [passwordMinLength] — la política real vive aquí, no en la pantalla.
  static String? password(String value, {int minLength = passwordMinLength}) {
    final minimoReal = minLength < passwordMinLength
        ? passwordMinLength
        : minLength;

    if (value.isEmpty) return 'Ingresa tu contraseña';
    if (value.length < minimoReal) {
      return 'Debe tener al menos $minimoReal caracteres';
    }
    if (value.length > passwordMaxLength) {
      return 'No puede superar los $passwordMaxLength caracteres';
    }

    final faltantes = <String>[];
    if (!_tieneMinuscula.hasMatch(value)) faltantes.add('una minúscula');
    if (!_tieneMayuscula.hasMatch(value)) faltantes.add('una mayúscula');
    if (!_tieneNumero.hasMatch(value)) faltantes.add('un número');

    if (faltantes.isNotEmpty) {
      return 'Debe incluir ${faltantes.join(', ')}';
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
    if (texto.length < nombreMinLength) return 'Ingresa un nombre válido';
    if (texto.length > nombreMaxLength) {
      return 'El nombre no puede superar los $nombreMaxLength caracteres';
    }
    return null;
  }

  /// Turistas nacionales y extranjeros pueden tener números de teléfono
  /// de distinta longitud según el país — ya no se exigen exactamente
  /// 10 dígitos, solo un rango razonable (10 a 15, como en la mayoría de
  /// los formatos internacionales reales).
  static String? telefono(String value) {
    final texto = value.trim();
    if (texto.isEmpty) return 'Ingresa tu teléfono';
    if (!_soloDigitos.hasMatch(texto)) {
      return 'El teléfono solo puede contener dígitos';
    }
    if (texto.length < telefonoMinDigitos ||
        texto.length > telefonoMaxDigitos) {
      return 'Debe tener entre $telefonoMinDigitos y $telefonoMaxDigitos '
          'dígitos';
    }
    return null;
  }
}
