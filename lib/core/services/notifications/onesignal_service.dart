import 'package:onesignal_flutter/onesignal_flutter.dart';

class OneSignalService {
  static const _appId = 'ee3de697-3022-4731-8d8c-759bfad87fec';

  static Future<void> initialize() async {
    OneSignal.initialize(_appId);
    await OneSignal.Notifications.requestPermission(true);
  }
}
