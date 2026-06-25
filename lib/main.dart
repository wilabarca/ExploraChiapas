// main.dart
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'app.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: false, // cámbialo a false para producción
      builder: (context) => const ExploraChiapasApp(),
    ),
  );
}
