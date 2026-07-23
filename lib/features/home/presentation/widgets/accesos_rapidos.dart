import 'package:flutter/material.dart';

class AccesosRapidos extends StatelessWidget {
  const AccesosRapidos({super.key});

  @override
  Widget build(BuildContext context) {
    final accesos = [
      {
        'icono': Icons.map_outlined,
        'label': 'Mapa',
        'ruta': '/mapa',
      },
      {
        'icono': Icons.favorite_outline,
        'label': 'Favoritos',
        'ruta': '/favoritos',
      },
      {
        'icono': Icons.event_outlined,
        'label': 'Eventos',
        'ruta': '/eventos',
      },
      {
        'icono': Icons.near_me_outlined,
        'label': 'Cerca',
        'ruta': '/cerca',
      },
      {
        'icono': Icons.add_location_alt_outlined,
        'label': 'Recomendar',
        'ruta': '/recomendar',
      },
    ];

    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: accesos.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          return GestureDetector(
            onTap: () =>
                Navigator.pushNamed(context, accesos[i]['ruta'] as String),
            child: Column(
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
            ),
          );
        },
      ),
    );
  }
}
