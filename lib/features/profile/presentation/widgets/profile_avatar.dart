import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final double radius;
  const ProfileAvatar({super.key, this.radius = 48});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFE8F5E9),
      child: Icon(
        Icons.person,
        size: radius,
        color: const Color(0xFF2E7D32),
      ),
    );
  }
}