import 'package:flutter/material.dart';

class ProfileStats extends StatelessWidget {
  const ProfileStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _Stat(valor: '12', label: 'Rutas'),
          _divider(),
          _Stat(valor: '34', label: 'Favoritos'),
          _divider(),
          _Stat(valor: '8',  label: 'Reseñas'),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        height: 36,
        width: 1,
        color: const Color(0xFFE0E0E0),
      );
}

class _Stat extends StatelessWidget {
  final String valor;
  final String label;
  const _Stat({required this.valor, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          valor,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B5E20),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF777777)),
        ),
      ],
    );
  }
}