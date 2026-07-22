import 'package:flutter/material.dart';

class AppNavigator {
  static final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();

  /// Observador de rutas compartido por toda la app. Permite a una página
  /// (p. ej. el Home) enterarse cuándo el usuario regresa a ella tras
  /// cerrar una pantalla apilada encima (`Navigator.pop`), usando el
  /// mecanismo estándar de Flutter (`RouteAware`) sin alterar la
  /// navegación existente.
  static final RouteObserver<PageRoute<dynamic>> routeObserver =
      RouteObserver<PageRoute<dynamic>>();
}
