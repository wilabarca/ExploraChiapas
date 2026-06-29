import 'package:flutter/material.dart';
import 'core/di/injector.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Debe ejecutarse antes de runApp para que getIt ya tenga todo registrado
  await configureDependencies();

  runApp(const ExploraChiapasApp());
}
