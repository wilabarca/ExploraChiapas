import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class OneSignalService {
  static const String _appId =
      'ee3de697-3022-4731-8d8c-759bfad87fec';

  static Future<void> initialize() async {
    await OneSignal.initialize(_appId);

    await OneSignal.Notifications.requestPermission(
      true,
    );
  }

  static Future<void> loginUser(
    String userId,
  ) async {
    if (userId.trim().isEmpty) {
      debugPrint(
        'OneSignal: no se pudo identificar '
        'al usuario porque userId está vacío',
      );
      return;
    }

    try {
      await OneSignal.login(userId);

      debugPrint(
        'OneSignal: usuario vinculado '
        'con external_id=$userId',
      );
    } catch (e) {
      debugPrint(
        'OneSignal: error vinculando usuario: $e',
      );
    }
  }

  static Future<void> logoutUser() async {
    try {
      await OneSignal.logout();

      debugPrint(
        'OneSignal: usuario desvinculado',
      );
    } catch (e) {
      debugPrint(
        'OneSignal: error cerrando identidad: $e',
      );
    }
  }
}