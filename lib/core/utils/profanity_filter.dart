class ProfanityFilter {
  static const Set<String> _palabras = {
    'puta','puto', 'putas', 'putos', 'putazo', 'putazos',
    'chinga', 'chingo', 'chingada', 'chingado', 'chingadas', 'chingados',
    'chingadera', 'chingaderas', 'chinguen', 'chingen',
    'cabron', 'cabrona', 'cabrones', 'cabronas',
    'pendejo', 'pendeja', 'pendejos', 'pendejas',
    'mierda', 'mierdas', 'mampo'
    'verga', 'vergas',
    'culero', 'culera', 'culeros', 'culeras',
    'joto', 'jota', 'jotos',
    'mamada', 'mamadas', 'mamon', 'mamonas',
    'ojete', 'ojetes',
    'pinche', 'pinches',
    'maricon', 'maricona', 'maricones',
    'cono',
    'nalgas',
    'fuck', 'shit', 'bitch', 'asshole', 'bastard',
  };

  static String _normalizar(String texto) {
    const reemplazos = {
      'á': 'a', 'à': 'a', 'ä': 'a',
      'é': 'e', 'è': 'e', 'ë': 'e',
      'í': 'i', 'ì': 'i', 'ï': 'i',
      'ó': 'o', 'ò': 'o', 'ö': 'o',
      'ú': 'u', 'ù': 'u', 'ü': 'u',
      'ñ': 'n',
    };
    var resultado = texto.toLowerCase();
    reemplazos.forEach((acento, letra) {
      resultado = resultado.replaceAll(acento, letra);
    });
    return resultado;
  }

  static bool contiene(String texto) {
    final tokens = texto.trim().split(RegExp(r'\s+'));
    for (final token in tokens) {
      final palabra = _normalizar(
        token.replaceAll(RegExp(r'[^a-zA-ZáéíóúüñÁÉÍÓÚÜÑ]'), ''),
      );
      if (palabra.isNotEmpty && _palabras.contains(palabra)) return true;
    }
    return false;
  }

  static String censurar(String texto) {
    return texto.splitMapJoin(
      RegExp(r'\S+'),
      onMatch: (m) {
        final token = m[0]!;
        final palabra = _normalizar(
          token.replaceAll(RegExp(r'[^a-zA-ZáéíóúüñÁÉÍÓÚÜÑ]'), ''),
        );
        if (palabra.isNotEmpty && _palabras.contains(palabra)) {
          return '*' * token.length;
        }
        return token;
      },
      onNonMatch: (s) => s,
    );
  }
}
