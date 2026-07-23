import 'package:flutter/material.dart';

import 'restaurante_item.dart';
import 'section_header.dart';

class _RestauranteData {
  final String nombre;
  final double calificacion;
  final double distanciaKm;
  final String descripcion;
  final String imageUrl;

  const _RestauranteData({
    required this.nombre,
    required this.calificacion,
    required this.distanciaKm,
    required this.descripcion,
    required this.imageUrl,
  });
}

const _restaurantes = [
  _RestauranteData(
    nombre: 'El Fogón de Jovel',
    calificacion: 4.7,
    distanciaKm: 2.4,
    descripcion: 'Especialidad en cocina de autor regional.',
    imageUrl:
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400&q=80',
  ),
  _RestauranteData(
    nombre: 'Café Maya Luxury',
    calificacion: 4.9,
    distanciaKm: 0.8,
    descripcion: 'El mejor café de altura de San Cristóbal.',
    imageUrl:
        'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400&q=80',
  ),
];

/// Sección "Restaurantes destacados" del Home. Se muestra apilada en
/// teléfono y en grid de 2 columnas en tablet, para no repetir esta
/// lógica responsiva en Home Turista y Home Local.
class RestaurantesDestacadosSection extends StatelessWidget {
  final String titulo;
  final String tituloTipo;

  const RestaurantesDestacadosSection({
    super.key,
    required this.titulo,
    required this.tituloTipo,
  });

  void _irANegocios(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/negocios',
      arguments: {'tipoNegocioId': 'restaurante', 'tituloTipo': tituloTipo},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          icon: Icons.restaurant_outlined,
          titulo: titulo,
          mostrarVerTodos: true,
          onVerTodos: () => _irANegocios(context),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth >= 600;

            final tarjetas = _restaurantes
                .map(
                  (r) => RestauranteItem(
                    nombre: r.nombre,
                    calificacion: r.calificacion,
                    distanciaKm: r.distanciaKm,
                    descripcion: r.descripcion,
                    imageUrl: r.imageUrl,
                    onTap: () => _irANegocios(context),
                  ),
                )
                .toList();

            if (isTablet) {
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.6,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: tarjetas,
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  for (var i = 0; i < tarjetas.length; i++) ...[
                    if (i > 0) const SizedBox(height: 12),
                    tarjetas[i],
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
