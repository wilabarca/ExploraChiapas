import 'package:flutter/material.dart';

class ProfileMenuItem extends StatelessWidget {
  final IconData  icon;
  final String    label;
  final VoidCallback onTap;
  final Color?    color;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? const Color(0xFF1B1B1B);
    return ListTile(
      leading: Icon(icon, color: c, size: 22),
      title: Text(
        label,
        style: TextStyle(fontSize: 15, color: c, fontWeight: FontWeight.w500),
      ),
      trailing: color == null
          ? const Icon(Icons.chevron_right, color: Color(0xFFCCCCCC))
          : null,
      onTap: onTap,
    );
  }
}