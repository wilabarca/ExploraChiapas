import 'package:flutter/material.dart';

/// Página de detalle para un lugar/destino turístico.
///
/// NOTA: Esta es una versión mínima temporal para desbloquear la
/// compilación. Reemplázala con la versión final una vez que definas
/// qué campos expone tu entidad de Destino (descripción, imágenes,
/// ubicación, municipio, etc.).
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
    return Scaffold(
      appBar: AppBar(
        title: Text(nombre),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  imageUrl,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 220,
                    color: const Color(0xFFE8F5E9),
                    child: const Icon(
                      Icons.image_not_supported_outlined,
                      size: 48,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              nombre,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B1B1B),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              categoria,
              style: const TextStyle(fontSize: 14, color: Color(0xFF888888)),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.star, size: 18, color: Color(0xFFFFC107)),
                const SizedBox(width: 4),
                Text(
                  calificacion.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Más información próximamente.',
              style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
            ),
          ],
        ),
      ),
    );
  }
}
