import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../destinos/presentation/pages/lugar_detail_page.dart';

class ChatPlaceCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const ChatPlaceCard({super.key, required this.data});

  void _abrirDetalle(BuildContext context) {
    final nombre = data['nombre'] as String? ?? 'Lugar';
    final categoria = data['categoria'] as String? ?? '';
    final descripcion = data['descripcion_corta'] as String? ?? '';
    final calificacion = (data['calificacion'] as num?)?.toDouble() ?? 0.0;
    final fotoUrl = data['foto_principal'] as String? ?? '';
    final idRaw = data['id'];
    final id = idRaw?.toString() ?? '';
    final coords = data['coordenadas'] as Map<String, dynamic>?;
    final lat = (coords?['lat'] as num?)?.toDouble();
    final lng = (coords?['lng'] as num?)?.toDouble();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LugarDetailPage(
          id: id,
          nombre: nombre,
          categoria: categoria,
          calificacion: calificacion,
          imageUrl: fotoUrl,
          descripcion: descripcion.isNotEmpty ? descripcion : null,
          lat: lat,
          lng: lng,
          // Recomendacion del chat/IA, no una fila real del backend: no
          // puede recibir resenas.
          targetType: null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nombre = data['nombre'] as String? ?? 'Lugar';
    final categoria = data['categoria'] as String? ?? '';
    final direccion = data['direccion'] as String? ?? '';
    final descripcion = data['descripcion_corta'] as String? ?? '';
    final fotoUrl = data['foto_principal'] as String?;
    final calificacion = (data['calificacion'] as num?)?.toDouble() ?? 0.0;
    final tiempoTraslado = data['tiempo_traslado_minutos'] as int?;
    final esRestaurante = categoria.toLowerCase().contains('restaurante');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen / placeholder
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: fotoUrl != null
                    ? CachedNetworkImage(
                        imageUrl: fotoUrl,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            _Placeholder(esRestaurante: esRestaurante),
                        errorWidget: (_, __, ___) =>
                            _Placeholder(esRestaurante: esRestaurante),
                      )
                    : _Placeholder(esRestaurante: esRestaurante),
              ),
              // Chip de categoría
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary(context).withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    esRestaurante ? 'Restaurante' : 'Destino',
                    style: TextStyle(
                      color: AppColors.onPrimary(context),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              // Tiempo de traslado (solo si viene del servidor)
              if (tiempoTraslado != null)
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.directions_car_outlined,
                          color: Colors.white,
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          tiempoTraslado < 60
                              ? '$tiempoTraslado min'
                              : '${(tiempoTraslado / 60).floor()} h ${tiempoTraslado % 60} min',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Calificación (solo si > 0)
              if (calificacion > 0)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface(context),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star,
                          color: Color(0xFFFFC107),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          calificacion.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          // Contenido
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                if (direccion.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.textSecondary(context),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          direccion,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (descripcion.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    descripcion,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _abrirDetalle(context),
                    icon: Icon(
                      esRestaurante
                          ? Icons.restaurant_outlined
                          : Icons.explore_outlined,
                      size: 18,
                      color: AppColors.onPrimary(context),
                    ),
                    label: Text(
                      esRestaurante ? 'Ver restaurante' : 'Ver destino',
                      style: TextStyle(
                        color: AppColors.onPrimary(context),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary(context),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final bool esRestaurante;
  const _Placeholder({required this.esRestaurante});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      color: AppColors.primaryContainer(context),
      child: Icon(
        esRestaurante ? Icons.restaurant : Icons.landscape,
        color: AppColors.primary(context).withValues(alpha: 0.4),
        size: 48,
      ),
    );
  }
}
