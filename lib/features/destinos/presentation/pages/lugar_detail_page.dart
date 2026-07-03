import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'calificar_resena_page.dart';

class LugarDetailPage extends StatelessWidget {
  final String nombre;
  final String categoria;
  final double calificacion;
  final String imageUrl;

  const LugarDetailPage({
    super.key,
    required this.nombre,
    required this.categoria,
    required this.calificacion,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final galeriaUrls = [
      'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&q=80',
      'https://images.unsplash.com/photo-1501854140801-50d01698950b?w=400&q=80',
      'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=400&q=80',
      'https://images.unsplash.com/photo-1518638150340-f706e86654de?w=400&q=80',
    ];

    final resenas = [
      {
        'usuario': 'María G.',
        'estrellas': 5,
        'comentario':
            'Un lugar impresionante, el color del agua es único. Totalmente recomendado.',
        'fecha': 'Jun 2026',
      },
      {
        'usuario': 'Carlos R.',
        'estrellas': 4,
        'comentario':
            'La naturaleza es increíble. El camino para llegar es un poco difícil pero vale la pena.',
        'fecha': 'May 2026',
      },
      {
        'usuario': 'Ana L.',
        'estrellas': 5,
        'comentario':
            'La mejor experiencia que he tenido en Chiapas. Volveré sin duda.',
        'fecha': 'Abr 2026',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(0xFF1B5E20),
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    Container(color: const Color(0xFFD8F5D8)),
                errorWidget: (_, __, ___) =>
                    Container(color: const Color(0xFFD8F5D8)),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          nombre,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B1B1B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star,
                                size: 14, color: Color(0xFFFFC107)),
                            const SizedBox(width: 4),
                            Text(
                              '$calificacion',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B5E20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          categoria,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Comunidad Explora',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF1565C0),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Galería de Exploradores',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B1B1B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 100,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: galeriaUrls.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                            imageUrl: galeriaUrls[index],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              width: 100,
                              height: 100,
                              color: const Color(0xFFD8F5D8),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              width: 100,
                              height: 100,
                              color: const Color(0xFFD8F5D8),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Reseñas',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B1B1B),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CalificarResenaPage(
                                nombreLugar: nombre,
                                imageUrl: imageUrl,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'Calificar',
                          style: TextStyle(
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...resenas.map((r) => _ResenaItem(resena: r)),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CalificarResenaPage(
                nombreLugar: nombre,
                imageUrl: imageUrl,
              ),
            ),
          );
        },
        backgroundColor: const Color(0xFF2E7D32),
        label: const Text('Escribir reseña',
            style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.edit_outlined, color: Colors.white),
      ),
    );
  }
}

class _ResenaItem extends StatelessWidget {
  final Map<String, dynamic> resena;
  const _ResenaItem({required this.resena});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFF2E7D32),
                    child: Text(
                      (resena['usuario'] as String)[0],
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    resena['usuario'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Text(
                resena['fecha'] as String,
                style:
                    const TextStyle(fontSize: 11, color: Color(0xFFAAAAAA)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(
              5,
              (i) => Icon(
                i < (resena['estrellas'] as int)
                    ? Icons.star
                    : Icons.star_outline,
                size: 14,
                color: const Color(0xFFFFC107),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            resena['comentario'] as String,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF444444),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
