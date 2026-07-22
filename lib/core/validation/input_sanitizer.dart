/// Validación y saneamiento de texto libre ingresado por el usuario antes
/// de enviarlo al backend. Es una capa de defensa adicional y de UX (dar un
/// mensaje claro de inmediato) — la protección real contra SQL injection
/// vive en el backend, que usa consultas parametrizadas ($1, $2, ...) en
/// vez de concatenar texto.
class InputSanitizer {
  InputSanitizer._();

  static final RegExp _htmlTag = RegExp(r'<[^>]*>');

  // Palabras/símbolos típicos de intentos de inyección SQL o de escapar
  // el campo hacia una consulta ("--", ";", comentarios de bloque, etc.).
  static final RegExp _sqlSospechoso = RegExp(
    r'(--|;|/\*|\*/|\bunion\b|\bselect\b|\binsert\b|\bdelete\b|\bdrop\b|\bupdate\b|\bexec\b|\bxp_cmdshell\b)',
    caseSensitive: false,
  );

  // Rango Unicode de emojis y pictogramas más comunes.
  static final RegExp _emoji = RegExp(
    r'[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}\u{2190}-\u{21FF}\u{2B00}-\u{2BFF}]',
    unicode: true,
  );

  // Caracteres de control invisibles (excluye \n \r \t, que sí pueden
  // aparecer en texto legítimo de varias líneas).
  static final RegExp _caracteresControl = RegExp(
    r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]',
  );

  /// Recorta espacios al inicio/final y colapsa espacios internos
  /// repetidos. Es lo primero que debe aplicarse a cualquier texto antes
  /// de validarlo o enviarlo.
  static String limpiar(String valor) {
    return valor.trim().replaceAll(RegExp(r'[ \t]+'), ' ');
  }

  static bool contieneHtml(String valor) => _htmlTag.hasMatch(valor);

  static bool contieneSqlSospechoso(String valor) =>
      _sqlSospechoso.hasMatch(valor);

  static bool contieneEmoji(String valor) => _emoji.hasMatch(valor);

  static bool contieneCaracteresControl(String valor) =>
      _caracteresControl.hasMatch(valor);

  /// Valida un campo de texto libre (ya recortado con [limpiar]).
  /// Devuelve un mensaje de error amigable, o `null` si es válido.
  static String? validarTexto(
    String valor, {
    required String etiqueta,
    int minLength = 1,
    required int maxLength,
    bool requerido = true,
  }) {
    final limpio = limpiar(valor);

    if (limpio.isEmpty) {
      return requerido ? '$etiqueta es obligatorio.' : null;
    }
    if (limpio.length < minLength) {
      return '$etiqueta debe tener al menos $minLength caracteres.';
    }
    if (limpio.length > maxLength) {
      return '$etiqueta no puede superar los $maxLength caracteres.';
    }
    if (contieneHtml(limpio)) {
      return '$etiqueta no puede contener etiquetas HTML.';
    }
    if (contieneSqlSospechoso(limpio)) {
      return '$etiqueta contiene caracteres o palabras no permitidas.';
    }
    if (contieneEmoji(limpio)) {
      return '$etiqueta no puede contener emojis.';
    }
    if (contieneCaracteresControl(limpio)) {
      return '$etiqueta contiene caracteres no válidos.';
    }
    return null;
  }
}
