import 'package:flutter/material.dart';
import 'core/di/injector.dart';
import 'core/services/notifications/onesignal_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await configureDependencies();
  await OneSignalService.initialize();

  runApp(const ExploraChiapasApp());
}
