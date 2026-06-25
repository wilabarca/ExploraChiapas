import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String emoji;
  final String titulo;
  final bool mostrarVerTodos;
  final VoidCallback? onVerTodos;

  const SectionHeader({
    super.key,
    required this.emoji,
    required this.titulo,
    this.mostrarVerTodos = false,
    this.onVerTodos,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B1B1B),
                ),
              ),
            ],
          ),
          if (mostrarVerTodos)
            GestureDetector(
              onTap: onVerTodos,
              child: const Text(
                'Ver todos',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
