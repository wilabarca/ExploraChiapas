import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FavoritosPage extends StatelessWidget {
  const FavoritosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F8F8),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1B1B1B)),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Mis Favoritos',
            style: TextStyle(
              color: Color(0xFF1B1B1B),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: const TabBar(
            labelColor: Color(0xFF2E7D32),
            unselectedLabelColor: Color(0xFF999999),
            indicatorColor: Color(0xFF2E7D32),
            tabs: [
              Tab(text: 'Destinos'),
              Tab(text: 'Rutas'),
              Tab(text: 'Experiencias'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _DestinosFavoritos(),
            _RutasFavoritas(),
            _ExperienciasFavoritas(),
          ],
        ),
      ),
    );
  }
}

class _DestinosFavoritos extends StatelessWidget {
  const _DestinosFavoritos();

  @override
  Widget build(BuildContext context) {
    final destinos = [
      {
        'nombre': 'Cascadas de Agua Azul',
        'categoria': 'Naturaleza',
        'calificacion': 4.9,
        'imagen':
            'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&q=80',
      },
      {
        'nombre': 'Zona Arqueológica Palenque',
        'categoria': 'Cultura',
        'calificacion': 4.8,
        'imagen':
            'https://images.unsplash.com/photo-1518638150340-f706e86654de?w=800&q=80',
      },
      {
        'nombre': 'Cañón del Sumidero',
        'categoria': 'Naturaleza',
        'calificacion': 4.7,
        'imagen':
            'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800&q=80',
      },
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: destinos.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final d = destinos[index];
        return _FavoritoCard(
          nombre: d['nombre'] as String,
          subtitulo: d['categoria'] as String,
          calificacion: d['calificacion'] as double,
          imageUrl: d['imagen'] as String,
        );
      },
    );
  }
}

class _RutasFavoritas extends StatelessWidget {
  const _RutasFavoritas();

  @override
  Widget build(BuildContext context) {
    final rutas = [
      {
        'nombre': 'Ruta Colonial San Cristóbal',
        'subtitulo': '3 destinos • 1 día',
        'calificacion': 4.6,
        'imagen':
            'https://images.unsplash.com/photo-1533587851505-d119e13fa0d7?w=800&q=80',
      },
      {
        'nombre': 'Selva y Cascadas',
        'subtitulo': '5 destinos • 2 días',
        'calificacion': 4.8,
        'imagen':
            'https://images.unsplash.com/photo-1501854140801-50d01698950b?w=800&q=80',
      },
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: rutas.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final r = rutas[index];
        return _FavoritoCard(
          nombre: r['nombre'] as String,
          subtitulo: r['subtitulo'] as String,
          calificacion: r['calificacion'] as double,
          imageUrl: r['imagen'] as String,
          icono: Icons.route_outlined,
        );
      },
    );
  }
}

class _ExperienciasFavoritas extends StatelessWidget {
  const _ExperienciasFavoritas();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.explore_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            'Sin experiencias guardadas',
            style: TextStyle(fontSize: 16, color: Color(0xFF999999)),
          ),
          const SizedBox(height: 8),
          const Text(
            'Explora y guarda las que más te interesen',
            style: TextStyle(fontSize: 13, color: Color(0xFFBBBBBB)),
          ),
        ],
      ),
    );
  }
}

class _FavoritoCard extends StatefulWidget {
  final String nombre;
  final String subtitulo;
  final double calificacion;
  final String imageUrl;
  final IconData icono;

  const _FavoritoCard({
    required this.nombre,
    required this.subtitulo,
    required this.calificacion,
    required this.imageUrl,
    this.icono = Icons.location_on_outlined,
  });

  @override
  State<_FavoritoCard> createState() => _FavoritoCardState();
}

class _FavoritoCardState extends State<_FavoritoCard> {
  bool _favorito = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(16),
            ),
            child: CachedNetworkImage(
              imageUrl: widget.imageUrl,
              width: 110,
              height: 90,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  Container(width: 110, height: 90, color: const Color(0xFFD8F5D8)),
              errorWidget: (_, __, ___) => Container(
                width: 110,
                height: 90,
                color: const Color(0xFFD8F5D8),
                child: const Icon(Icons.image_not_supported, color: Colors.white54),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.nombre,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B1B1B),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(widget.icono,
                          size: 13, color: const Color(0xFF2E7D32)),
                      const SizedBox(width: 4),
                      Text(
                        widget.subtitulo,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF888888),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 13, color: Color(0xFFFFC107)),
                      const SizedBox(width: 3),
                      Text(
                        '${widget.calificacion}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF555555),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _favorito = !_favorito),
            icon: Icon(
              _favorito ? Icons.favorite : Icons.favorite_outline,
              color: _favorito ? Colors.red : Colors.grey,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
