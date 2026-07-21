class ProfanityFilter {
  // Palabras exactas (tras normalización)
  static const Set<String> _palabras = {
    // ── puta / puto ──────────────────────────────────────────────
    'puta', 'puto', 'putas', 'putos', 'putazo', 'putazos',
    'putear', 'puteada', 'puteado', 'puteadas', 'puteados',
    'puteria', 'puterias', 'puti', 'puticlub',

    // ── chinga ───────────────────────────────────────────────────
    'chinga', 'chingo', 'chingas', 'chingaste', 'chingaron',
    'chingada', 'chingado', 'chingadas', 'chingados',
    'chingadera', 'chingaderas', 'chinguen', 'chingen',
    'chingon', 'chingona', 'chingones', 'chingonas',
    'chingarse', 'chingue', 'chinguense',

    // ── cabrón ───────────────────────────────────────────────────
    'cabron', 'cabrona', 'cabrones', 'cabronas',
    'cabronazo', 'cabronaza', 'cabronada', 'cabronadas',

    // ── pendejo ──────────────────────────────────────────────────
    'pendejo', 'pendeja', 'pendejos', 'pendejas',
    'pendejada', 'pendejadas', 'pendejez',

    // ── mierda ───────────────────────────────────────────────────
    'mierda', 'mierdas', 'mierdon', 'mierdona',
    'mierdonas', 'mierdones',
    'cagar', 'caga', 'cagas', 'cago', 'cagaste', 'cagaron',
    'cagada', 'cagado', 'cagadas', 'cagados', 'cagarse',
    'caguen', 'cague',

    // ── verga ────────────────────────────────────────────────────
    'verga', 'vergas', 'vergon', 'vergona', 'vergones',
    'vergudo', 'verguda',

    // ── culo / culero ────────────────────────────────────────────
    'culo', 'culos', 'culito', 'culona', 'culones', 'culonas',
    'culero', 'culera', 'culeros', 'culeras', 'culerismo',

    // ── coño ─────────────────────────────────────────────────────
    'cono', 'conos', 'concha', 'conchas', 'conchuda', 'conchudo',

    // ── joto ─────────────────────────────────────────────────────
    'joto', 'jota', 'jotos', 'jotas', 'jotear', 'joteado',

    // ── mamada / mamón ───────────────────────────────────────────
    'mamada', 'mamadas', 'mamon', 'mamona', 'mamones', 'mamonas',

    // ── ojete ────────────────────────────────────────────────────
    'ojete', 'ojetes', 'ojeteada', 'ojeteado',

    // ── pinche ───────────────────────────────────────────────────
    'pinche', 'pinches', 'pinchada', 'pinchado',

    // ── maricón ──────────────────────────────────────────────────
    'maricon', 'maricona', 'maricones',
    'marica', 'maricas', 'maricada', 'maricadas',

    // ── nalga ────────────────────────────────────────────────────
    'nalga', 'nalgas', 'nalgon', 'nalgona', 'nalgones', 'nalgonas',

    // ── pito / pija ──────────────────────────────────────────────
    'pito', 'pitos', 'pija', 'pijas',

    // ── panocha / chocho ─────────────────────────────────────────
    'panocha', 'panochas', 'chocho', 'chucha', 'chuchas',

    // ── coger ────────────────────────────────────────────────────
    'coger', 'coge', 'coges', 'cogi', 'cogiste', 'cogieron',
    'cogida', 'cogido', 'cogidas', 'cogidos', 'cojerse',

    // ── carajo ───────────────────────────────────────────────────
    'carajo', 'carajos',

    // ── madres (mexican slang) ───────────────────────────────────
    'chingalamadre', 'chingalamadres', 'hijueputa', 'hijuepuetas',
    'hijoeputa',

    // ── huevón ───────────────────────────────────────────────────
    'huevon', 'huevona', 'huevones', 'huevonas',
    'weon', 'weona', 'weones',


    // ── otros español regional ───────────────────────────────────
    'malparido', 'malparida', 'malparidos', 'malparidas',
    'gonorrea', 'gonorreas',
    'hijodeputa', 'hijasdeputa',
    'putisimo', 'putisima',

    // ── inglés ───────────────────────────────────────────────────
    'fuck', 'fucker', 'fuckers', 'fucking', 'fucked', 'fucks',
    'fuckin', 'motherfucker', 'motherfuckers',
    'shit', 'shits', 'bullshit', 'shitty', 'shithead',
    'bitch', 'bitches', 'bitchy', 'sobitch',
    'asshole', 'assholes', 'ass',
    'bastard', 'bastards',
    'cunt', 'cunts',
    'cock', 'cocks', 'cocksucker',
    'dick', 'dicks', 'dickhead',
    'pussy', 'pussies',
    'whore', 'whores',
    'nigger', 'nigga', 'niggas',
    'faggot', 'faggots', 'fag', 'fags',
    'slut', 'sluts',
    'twat', 'twats',
    'wanker', 'wankers',
    'prick', 'pricks',
    'idiot', 'idiots',
    'moron', 'morons',
    'retard', 'retarded',
    'dumbass', 'dumbasses',
    'dipshit', 'dipshits',
    'jackass', 'jackasses',
    'scumbag', 'scumbags',
    'piece of shit',
    'son of a bitch',
    'go to hell',
  };

  static String _normalizar(String texto) {
    // Mapea acentos Y leet-speak comunes
    const reemplazos = {
      // Acentos
      'á': 'a', 'à': 'a', 'ä': 'a',
      'é': 'e', 'è': 'e', 'ë': 'e',
      'í': 'i', 'ì': 'i', 'ï': 'i',
      'ó': 'o', 'ò': 'o', 'ö': 'o',
      'ú': 'u', 'ù': 'u', 'ü': 'u',
      'ñ': 'n',
      // Leet-speak
      '@': 'a',
      '4': 'a',
      '3': 'e',
      '1': 'i',
      '!': 'i',
      '0': 'o',
      r'$': 's',
      '5': 's',
      '7': 't',
    };
    var resultado = texto.toLowerCase();
    reemplazos.forEach((original, reemplazo) {
      resultado = resultado.replaceAll(original, reemplazo);
    });
    return resultado;
  }

  static bool contiene(String texto) {
    final tokens = _normalizar(texto).trim().split(RegExp(r'\s+'));
    for (final token in tokens) {
      final palabra = token.replaceAll(RegExp(r'[^a-z]'), '');
      if (palabra.isNotEmpty && _palabras.contains(palabra)) return true;
    }
    // Verificar frases multi-palabra (piece of shit, son of a bitch, etc.)
    final textoNorm = _normalizar(texto);
    for (final frase in _palabras) {
      if (frase.contains(' ') && textoNorm.contains(frase)) return true;
    }
    return false;
  }

  static String censurar(String texto) {
    return texto.splitMapJoin(
      RegExp(r'\S+'),
      onMatch: (m) {
        final token = m[0]!;
        final palabra =
            _normalizar(token).replaceAll(RegExp(r'[^a-z]'), '');
        if (palabra.isNotEmpty && _palabras.contains(palabra)) {
          return '*' * token.length;
        }
        return token;
      },
      onNonMatch: (s) => s,
    );
  }
}
