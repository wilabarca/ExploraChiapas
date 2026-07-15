import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/resena_entity.dart';
import '../../domain/entities/resenas_fake_data.dart';
import '../widgets/resena_card.dart';
import '../widgets/star_rating.dart';
import 'escribir_resena_page.dart';

class DetalleResenaPage extends StatelessWidget {
  final DestinoResenaEntity destino;

  const DetalleResenaPage({super.key, required this.destino});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    // Desglose de estrellas ficticio
    final desglose = {5: 0.72, 4: 0.18, 3: 0.06, 2: 0.02, 1: 0.02};

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2E7D32)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'ExploraChiapas',
          style: TextStyle(
            color: Color(0xFF2E7D32),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFD8F5D8),
              child: const Icon(
                Icons.person,
                color: Color(0xFF2E7D32),
                size: 20,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EscribirResenaPage(destino: destino),
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        icon: const Icon(Icons.edit, color: Colors.white),
        label: const Text(
          'Escribir Reseña',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        children: [
          // ── Imagen principal ──────────────────────────────────────────
          // ✓ AspectRatio proporcional para la imagen hero
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: destino.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) =>
                      Container(color: const Color(0xFFD8F5D8)),
                  errorWidget: (_, __, ___) => Container(
                    color: const Color(0xFFD8F5D8),
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.white54,
                    ),
                  ),
                ),
                // Gradiente sobre la imagen
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.6),
                      ],
                      stops: const [0.5, 1.0],
                    ),
                  ),
                ),
                if (destino.esPopular)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'DESTINO POPULAR',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        destino.nombre,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.white70,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            destino.ubicacion,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Resumen de calificación ────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // ✓ FractionallySizedBox para el número grande de calificación
                FractionallySizedBox(
                  widthFactor: 1.0,
                  child: Row(
                    children: [
                      // Número grande
                      Column(
                        children: [
                          Text(
                            '${destino.calificacion}',
                            style: const TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B1B1B),
                              height: 1,
                            ),
                          ),
                          StarRating(rating: destino.calificacion, size: 20),
                          const SizedBox(height: 4),
                          Text(
                            '${destino.totalResenas} RESEÑAS',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF888888),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 24),
                      // Desglose de estrellas
                      Expanded(
                        child: Column(
                          children: desglose.entries.map((e) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: [
                                  Text(
                                    '${e.key}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF888888),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  // ✓ Expanded distribuye el espacio de la barra
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: e.value,
                                        backgroundColor: const Color(
                                          0xFFEEEEEE,
                                        ),
                                        valueColor:
                                            const AlwaysStoppedAnimation(
                                              Color(0xFF2E7D32),
                                            ),
                                        minHeight: 8,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${(e.value * 100).toInt()}%',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF888888),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ── Lista de comentarios ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Comentarios',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B1B1B),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Recientes ▾',
                    style: TextStyle(color: Color(0xFF2E7D32), fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

          // ✓ ListView de reseñas con separadores
          ...resenasFake.map(
            (resena) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: ResenaCard(resena: resena),
            ),
          ),

          // Botón cargar más
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF2E7D32)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Cargar más reseñas',
                style: TextStyle(
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
