import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const _kLocale = 'pref_locale';

  Locale _locale = const Locale('es');
  Locale get locale => _locale;

  String get langCode => _locale.languageCode;

  Future<void> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    final code  = prefs.getString(_kLocale) ?? 'es';
    _locale = Locale(code);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocale, locale.languageCode);
    notifyListeners();
  }
}
