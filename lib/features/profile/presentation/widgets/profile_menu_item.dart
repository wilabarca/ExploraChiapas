import 'package:flutter/material.dart';

class ProfileMenuItem extends StatelessWidget {
  final IconData icono;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? labelColor;
  final Color? bgColor;

  const ProfileMenuItem({
    super.key,
    required this.icono,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.labelColor,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor ?? Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (iconColor ?? const Color(0xFF2E7D32)).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icono,
                color: iconColor ?? const Color(0xFF2E7D32),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: labelColor ?? const Color(0xFF1B1B1B),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: labelColor ?? const Color(0xFF888888),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}