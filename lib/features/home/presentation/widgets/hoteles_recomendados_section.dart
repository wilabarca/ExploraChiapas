import 'package:flutter/material.dart';

import 'hotel_card.dart';
import 'section_header.dart';

class _HotelData {
  final String nombre;
  final double precioPorNoche;
  final String imageUrl;

  const _HotelData({
    required this.nombre,
    required this.precioPorNoche,
    required this.imageUrl,
  });
}

const _hoteles = [
  _HotelData(
    nombre: 'Selva Verde Eco-Resort',
    precioPorNoche: 2400.0,
    imageUrl:
        'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=400&q=80',
  ),
  _HotelData(
    nombre: 'Boutique Casa Lum',
    precioPorNoche: 3100.0,
    imageUrl:
        'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=400&q=80',
  ),
];

/// Sección "Hoteles recomendados" del Home. Carrusel horizontal en
/// teléfono y grid en tablet, compartido entre Home Turista y Home
/// Local para no duplicar esta lógica responsiva.
class HotelesRecomendadosSection extends StatelessWidget {
  final String titulo;
  final String tituloTipo;

  const HotelesRecomendadosSection({
    super.key,
    required this.titulo,
    required this.tituloTipo,
  });

  void _irANegocios(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/negocios',
      arguments: {'tipoNegocioId': 'hotel', 'tituloTipo': tituloTipo},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          icon: Icons.hotel_outlined,
          titulo: titulo,
          mostrarVerTodos: true,
          onVerTodos: () => _irANegocios(context),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            final isTablet = maxWidth >= 600;
            final isLarge = maxWidth >= 900;

            if (isTablet) {
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isLarge ? 3 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.95,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: _hoteles
                    .map(
                      (h) => HotelCard(
                        nombre: h.nombre,
                        precioPorNoche: h.precioPorNoche,
                        imageUrl: h.imageUrl,
                        onTap: () => _irANegocios(context),
                      ),
                    )
                    .toList(),
              );
            }

            return SizedBox(
              height: 212,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _hoteles.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final h = _hoteles[index];
                  return HotelCard(
                    nombre: h.nombre,
                    precioPorNoche: h.precioPorNoche,
                    imageUrl: h.imageUrl,
                    onTap: () => _irANegocios(context),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
