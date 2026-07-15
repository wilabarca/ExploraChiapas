import 'package:flutter/material.dart';

/// Ítem de menú reutilizable para la sección inferior del perfil.
/// Soporta color de peligro (rojo) para acciones destructivas.
class ProfileMenuItem extends StatelessWidget {
  final IconData     icon;
  final String       label;
  final VoidCallback onTap;

  /// Si se especifica, aplica color de peligro al ícono y texto.
  final Color? dangerColor;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.dangerColor,
  });

  @override
  Widget build(BuildContext context) {
    final c = dangerColor ?? const Color(0xFF1B1B1B);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: dangerColor != null
                    ? const Color(0xFFFFEBEE)
                    : const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: c, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: c,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: c.withOpacity(0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}