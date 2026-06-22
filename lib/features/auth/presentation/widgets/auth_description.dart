import 'package:flutter/material.dart';

class AuthDescription extends StatelessWidget {
  const AuthDescription({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'Explora la Magia\nde Chiapas',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 38,
            fontWeight: FontWeight.bold,
            height: 1.15,
          ),
        ),

        SizedBox(height: 20),

        Text(
          'Tu aventura sostenible comienza aquí.\n'
          'Descubre rutas únicas y apoya a las\n'
          'comunidades locales.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}