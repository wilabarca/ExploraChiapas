import 'package:flutter/material.dart';
import 'core/di/injector.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ← esto debe ejecutarse ANTES de runApp
  await configureDependencies();

  runApp(const ExploraChiapasApp());
}
