import 'package:flutter/material.dart';

class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250, // era 200
      height: 400, // era 265
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: AssetImage('assets/images/inicio.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
