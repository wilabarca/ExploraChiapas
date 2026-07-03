import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ExplorarCercaPage extends StatelessWidget {
  const ExplorarCercaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B1B1B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Explorar cerca de mí',
          style: TextStyle(
            color: Color(0xFF1B1B1B),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Icon(Icons.explore_outlined, color: Color(0xFF2E7D32)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Descubre los tesoros de Chiapas cerca de tu ubicación actual.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF1B5E20),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _CategoriaGrande(
              titulo: 'Lugares cercanos',
              icono: Icons.location_on_outlined,
              imageUrl:
                  'https://images.unsplash.com/photo-1480714378408-67cf0d13bc1b?w=800&q=80',
              onTap: () {},
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _CategoriaChica(
                    titulo: 'Restaurantes',
                    icono: Icons.restaurant_outlined,
                    color: const Color(0xFFFFF3E0),
                    iconColor: const Color(0xFFE65100),
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CategoriaChica(
                    titulo: 'Hoteles',
                    icono: Icons.hotel_outlined,
                    color: const Color(0xFFE3F2FD),
                    iconColor: const Color(0xFF1565C0),
                    onTap: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _CategoriaChica(
                    titulo: 'Naturaleza',
                    icono: Icons.park_outlined,
                    color: const Color(0xFFE8F5E9),
                    iconColor: const Color(0xFF2E7D32),
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CategoriaChica(
                    titulo: 'Cultura',
                    icono: Icons.museum_outlined,
                    color: const Color(0xFFF3E5F5),
                    iconColor: const Color(0xFF6A1B9A),
                    onTap: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _CategoriaChica(
                    titulo: 'Aventura',
                    icono: Icons.terrain_outlined,
                    color: const Color(0xFFFFEBEE),
                    iconColor: const Color(0xFFC62828),
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CategoriaChica(
                    titulo: 'Eventos',
                    icono: Icons.event_outlined,
                    color: const Color(0xFFF9FBE7),
                    iconColor: const Color(0xFF558B2F),
                    onTap: () => Navigator.pushNamed(context, '/eventos'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Más visitados hoy',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B1B1B),
              ),
            ),
            const SizedBox(height: 12),
            _LugarCercanoItem(
              nombre: 'Cascadas de Agua Azul',
              distancia: '42 km',
              categoria: 'Naturaleza',
              imageUrl:
                  'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&q=80',
            ),
            const SizedBox(height: 10),
            _LugarCercanoItem(
              nombre: 'Cañón del Sumidero',
              distancia: '8 km',
              categoria: 'Naturaleza',
              imageUrl:
                  'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=400&q=80',
            ),
            const SizedBox(height: 10),
            _LugarCercanoItem(
              nombre: 'Mercado de Santo Domingo',
              distancia: '1.2 km',
              categoria: 'Cultura',
              imageUrl:
                  'https://images.unsplash.com/photo-1533587851505-d119e13fa0d7?w=400&q=80',
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _CategoriaGrande extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final String imageUrl;
  final VoidCallback onTap;

  const _CategoriaGrande({
    required this.titulo,
    required this.icono,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: imageUrl,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  Container(height: 160, color: const Color(0xFFD8F5D8)),
              errorWidget: (_, __, ___) =>
                  Container(height: 160, color: const Color(0xFFD8F5D8)),
            ),
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black54, Colors.transparent],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 14,
              left: 14,
              child: Row(
                children: [
                  Icon(icono, color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    titulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoriaChica extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _CategoriaChica({
    required this.titulo,
    required this.icono,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, color: iconColor, size: 28),
            const SizedBox(height: 6),
            Text(
              titulo,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: iconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LugarCercanoItem extends StatelessWidget {
  final String nombre;
  final String distancia;
  final String categoria;
  final String imageUrl;

  const _LugarCercanoItem({
    required this.nombre,
    required this.distancia,
    required this.categoria,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  Container(width: 70, height: 70, color: const Color(0xFFD8F5D8)),
              errorWidget: (_, __, ___) =>
                  Container(width: 70, height: 70, color: const Color(0xFFD8F5D8)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B1B1B),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  categoria,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF888888)),
                ),
              ],
            ),
          ),
          Column(
            children: [
              const Icon(Icons.near_me_outlined,
                  size: 14, color: Color(0xFF2E7D32)),
              const SizedBox(height: 2),
              Text(
                distancia,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
