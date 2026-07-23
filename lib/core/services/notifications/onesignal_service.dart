import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../../navigation/app_navigator.dart';

class OneSignalService {
  static const String _appId = 'ee3de697-3022-4731-8d8c-759bfad87fec';

  // Saved when the navigator isn't mounted yet (cold-start tap).
  static String? _rutaPendiente;
  static Map<String, dynamic>? _argsPendientes;

  static Future<void> initialize() async {
    await OneSignal.initialize(_appId);

    await OneSignal.Notifications.requestPermission(true);

    // Show notification banner while the app is open.
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      event.notification.display();
    });

    // Handle tap in all app states: foreground, background, cold-start.
    OneSignal.Notifications.addClickListener(_onNotificationClick);
  }

  static void _onNotificationClick(OSNotificationClickEvent event) {
    final data = event.notification.additionalData;
    final ruta = _rutaDesdeDatos(data);
    if (ruta == null) return;

    final nav = AppNavigator.key.currentState;
    if (nav != null) {
      nav.pushNamed(ruta, arguments: _argsDesdeDatos(data));
    } else {
      // Navigator not ready (cold-start) — flush later from app widget.
      _rutaPendiente = ruta;
      _argsPendientes = _argsDesdeDatos(data);
    }
  }

  /// Call from ExploraChiapasApp.initState (post-frame) so that any
  /// cold-start tap navigation fires once the navigator is mounted.
  static void flushPendingNavigation() {
    if (_rutaPendiente == null) return;
    final nav = AppNavigator.key.currentState;
    if (nav == null) return;
    final ruta = _rutaPendiente!;
    final args = _argsPendientes;
    _rutaPendiente = null;
    _argsPendientes = null;
    nav.pushNamed(ruta, arguments: args);
  }

  // ── helpers ──────────────────────────────────────────────────────────────

  static String? _rutaDesdeDatos(Map<String, dynamic>? data) {
    final tipo = data?['type']?.toString();
    if (tipo == 'evento') return '/eventos';
    if (tipo == 'promocion') return '/promociones';
    return null;
  }

  static Map<String, dynamic>? _argsDesdeDatos(Map<String, dynamic>? data) {
    final tipo = data?['type']?.toString();
    if (tipo == 'promocion') {
      final negocioId = data?['negocioId']?.toString();
      return negocioId != null ? {'negocioId': negocioId} : null;
    }
    return null;
  }

  // ── auth lifecycle ────────────────────────────────────────────────────────

  static Future<void> loginUser(String userId) async {
    if (userId.trim().isEmpty) {
      debugPrint('OneSignal: userId vacío, sin vincular');
      return;
    }
    try {
      await OneSignal.login(userId);
      debugPrint('OneSignal: vinculado external_id=$userId');
    } catch (e) {
      debugPrint('OneSignal: error vinculando usuario: $e');
    }
  }

  static Future<void> logoutUser() async {
    try {
      await OneSignal.logout();
      debugPrint('OneSignal: usuario desvinculado');
    } catch (e) {
      debugPrint('OneSignal: error cerrando identidad: $e');
    }
  }
}
