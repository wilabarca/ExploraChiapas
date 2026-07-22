import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../theme/app_colors.dart';

class LocationPermissionHelper {
  final LocationService _service = LocationService();

  // Para el onboarding (interests_page)
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

  Future<void> checkAndRequestOnLogin(BuildContext context) async {
    final has = await _service.hasPermission();
    if (!has) {
      if (!context.mounted) return;
      await requestWithDialog(context);
    }
    // Si ya tiene permiso no hace nada
  }

  Future<void> _showBlockedDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.location_off_outlined,
              color: AppColors.primary(ctx),
              size: 26,
            ),
            const SizedBox(width: 10),
            Text(
              'Ubicación bloqueada',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.primary(ctx),
              ),
            ),
          ],
        ),
        content: Text(
          'Bloqueaste el permiso de ubicación.\n\n'
          'Para activarlo ve a:\n'
          'Ajustes → Aplicaciones → ExploraChiapas '
          '→ Permisos → Ubicación',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary(ctx),
            height: 1.6,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Ahora no',
              style: TextStyle(color: AppColors.textSecondary(ctx)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              LocationService().openSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary(ctx),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Ir a Ajustes',
              style: TextStyle(color: AppColors.onPrimary(ctx)),
            ),
          ),
        ],
      ),
    );
  }
}
