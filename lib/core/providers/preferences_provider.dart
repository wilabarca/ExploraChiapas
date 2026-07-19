import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesProvider extends ChangeNotifier {
  static const _kIdioma              = 'pref_idioma';
  static const _kUnidades            = 'pref_unidades';
  static const _kTema                = 'pref_tema';
  static const _kMoneda              = 'pref_moneda';
  static const _kCompartirUbicacion  = 'pref_compartir_ubicacion';
  static const _kCompartirHistorial  = 'pref_compartir_historial';
  static const _kMostrarPerfil       = 'pref_mostrar_perfil_publico';

  String _idioma   = 'Español';
  String _unidades = 'km';
  String _tema     = 'Claro';
  String _moneda   = 'MXN';
  bool _compartirUbicacion  = false;
  bool _compartirHistorial  = false;
  bool _mostrarPerfilPublico = true;

  String get idioma   => _idioma;
  String get unidades => _unidades;
  String get tema     => _tema;
  String get moneda   => _moneda;
  bool get compartirUbicacion   => _compartirUbicacion;
  bool get compartirHistorial   => _compartirHistorial;
  bool get mostrarPerfilPublico => _mostrarPerfilPublico;

  ThemeMode get themeMode =>
      _tema == 'Oscuro' ? ThemeMode.dark : ThemeMode.light;

  Future<void> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    _idioma   = prefs.getString(_kIdioma)   ?? 'Español';
    _unidades = prefs.getString(_kUnidades) ?? 'km';
    _tema     = prefs.getString(_kTema)     ?? 'Claro';
    _moneda   = prefs.getString(_kMoneda)   ?? 'MXN';
    _compartirUbicacion  = prefs.getBool(_kCompartirUbicacion)  ?? false;
    _compartirHistorial  = prefs.getBool(_kCompartirHistorial)  ?? false;
    _mostrarPerfilPublico = prefs.getBool(_kMostrarPerfil)       ?? true;
    notifyListeners();
  }

  Future<void> setIdioma(String v) async {
    _idioma = v;
    await _guardar(_kIdioma, v);
  }

  Future<void> setUnidades(String v) async {
    _unidades = v;
    await _guardar(_kUnidades, v);
  }

  Future<void> setTema(String v) async {
    _tema = v;
    await _guardar(_kTema, v);
  }

  Future<void> setMoneda(String v) async {
    _moneda = v;
    await _guardar(_kMoneda, v);
  }

  Future<void> setCompartirUbicacion(bool v) async {
    _compartirUbicacion = v;
    await _guardarBool(_kCompartirUbicacion, v);
  }

  Future<void> setCompartirHistorial(bool v) async {
    _compartirHistorial = v;
    await _guardarBool(_kCompartirHistorial, v);
  }

  Future<void> setMostrarPerfilPublico(bool v) async {
    _mostrarPerfilPublico = v;
    await _guardarBool(_kMostrarPerfil, v);
  }

  Future<void> _guardar(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
    notifyListeners();
  }

  Future<void> _guardarBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    notifyListeners();
  }
}
