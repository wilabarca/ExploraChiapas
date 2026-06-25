import 'package:flutter/material.dart';

class AccesosRapidos extends StatelessWidget {
  const AccesosRapidos({super.key});

  @override
  Widget build(BuildContext context) {
    final accesos = [
      {'icono': Icons.map_outlined, 'label': 'Mapa'},
      {'icono': Icons.favorite_outline, 'label': 'Favoritos'},
      {'icono': Icons.history, 'label': 'Historial'},
    ];

    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: accesos.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          return Column(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FAF0),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFD8F5D8)),
                ),
                child: Icon(
                  accesos[i]['icono'] as IconData,
                  color: const Color(0xFF2E7D32),
                  size: 24,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                accesos[i]['label'] as String,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF555555),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}