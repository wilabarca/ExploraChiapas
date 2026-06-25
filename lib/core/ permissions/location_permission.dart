import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

class LocationPermissionHelper {
  final LocationService _service = LocationService();

  /// Usado en onboarding (InterestsPage): pide permiso la primera vez.
  Future<bool> requestWithDialog(BuildContext context) async {
    final permission = await _service.requestPermission();

    if (permission == LocationPermission.deniedForever) {
      if (!context.mounted) return false;
      await _showBlockedDialog(context);
      return false;
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Usado en login: solo pide si el usuario revocó el permiso.
  /// No bloquea la navegación al home.
  Future<void> checkAndRequestOnLogin(BuildContext context) async {
    final alreadyGranted = await _service.hasPermission();
    if (alreadyGranted) return; // permiso vigente, no molestamos

    if (!context.mounted) return;
    await requestWithDialog(context);
  }

  Future<void> _showBlockedDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.location_off_outlined,
                color: Color(0xFF2E7D32), size: 26),
            SizedBox(width: 10),
            Text(
              'Ubicación bloqueada',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),
          ],
        ),
        content: const Text(
          'Bloqueaste el permiso de ubicación.\n\n'
          'Para activarlo ve a:\n'
          'Ajustes → Aplicaciones → ExploraChiapas '
          '→ Permisos → Ubicación',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF555555),
            height: 1.6,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Ahora no',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              LocationService().openSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Ir a Ajustes',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}