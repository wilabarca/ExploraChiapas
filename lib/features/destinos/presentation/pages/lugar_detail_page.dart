import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

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
        backgroundColor: AppColors.primary(context),
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
                    color: AppColors.primaryContainer(context),
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      size: 48,
                      color: AppColors.primary(context),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              nombre,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              categoria,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary(context)),
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
            Text(
              'Más información próximamente.',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary(context)),
            ),
          ],
        ),
      ),
    );
  }
}
