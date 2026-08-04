import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/press_scale.dart';
import '../../../destinos/presentation/pages/lugar_detail_page.dart';
import '../../../destinos/presentation/pages/mapa_ruta_page.dart';

/// Tarjeta de un lugar recomendado por la IA (parseada de un bloque
/// ```card``` embebido en la respuesta del modelo — ver
/// `ChatRoutesPage._parsearConCards`). El favorito/reseña reales viven en
/// `LugarDetailPage`: el `id` que da el modelo es interno del servicio de
/// recomendación, no necesariamente un UUID del backend, así que no se
/// duplica aquí un botón de favorito que podría apuntar a un recurso que
/// no existe — se mantiene la misma regla ya aplicada (`targetType: null`
/// para lugares no reseñables).
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

  (double, double)? get _coordenadas {
    final coords = data['coordenadas'] as Map<String, dynamic>?;
    final lat = (coords?['lat'] as num?)?.toDouble();
    final lng = (coords?['lng'] as num?)?.toDouble();
    if (lat == null || lng == null) return null;
    return (lat, lng);
  }

  void _trazarRuta(BuildContext context) {
    final coords = _coordenadas;
    if (coords == null) return;
    final nombre = data['nombre'] as String? ?? 'Lugar';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapaRutaPage(
          nombre: nombre,
          destLat: coords.$1,
          destLng: coords.$2,
        ),
      ),
    );
  }

  void _compartir(String nombre, String descripcion) {
    SharePlus.instance.share(
      ShareParams(
        text: descripcion.isNotEmpty
            ? '¡Descubre $nombre en ExploraChiapas!\n$descripcion'
            : '¡Descubre $nombre en ExploraChiapas!',
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
    final tieneCoordenadas = _coordenadas != null;

    return FadeSlideIn(
      offsetY: 14,
      child: PressScale(
        scaleAbajo: 0.985,
        onTap: () => _abrirDetalle(context),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: AppColors.isDark(context) ? 0.3 : 0.08,
                ),
                blurRadius: 14,
                offset: const Offset(0, 5),
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
                      top: Radius.circular(22),
                    ),
                    child: fotoUrl != null && fotoUrl.trim().isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: fotoUrl,
                            height: 190,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (_, _) =>
                                _Placeholder(esRestaurante: esRestaurante),
                            errorWidget: (_, _, _) =>
                                _Placeholder(esRestaurante: esRestaurante),
                          )
                        : _Placeholder(esRestaurante: esRestaurante),
                  ),
                  // Chip de categoría
                  Positioned(
                    top: 12,
                    left: 12,
                    child: _Chip(
                      icon: esRestaurante
                          ? Icons.restaurant_outlined
                          : Icons.explore_outlined,
                      texto: esRestaurante ? 'Restaurante' : 'Destino',
                      fondo: AppColors.primary(context).withValues(alpha: 0.92),
                      color: AppColors.onPrimary(context),
                    ),
                  ),
                  // Compartir
                  Positioned(
                    top: 10,
                    right: 10,
                    child: PressScale(
                      scaleAbajo: 0.88,
                      onTap: () => _compartir(nombre, descripcion),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(
                          color: Colors.black45,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.share_outlined,
                          color: Colors.white,
                          size: 17,
                        ),
                      ),
                    ),
                  ),
                  // Tiempo de traslado (solo si viene del servidor)
                  if (tiempoTraslado != null)
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: _Chip(
                        icon: Icons.directions_car_outlined,
                        texto: tiempoTraslado < 60
                            ? '$tiempoTraslado min'
                            : '${(tiempoTraslado / 60).floor()} h ${tiempoTraslado % 60} min',
                        fondo: Colors.black54,
                        color: Colors.white,
                      ),
                    ),

                  // Calificación (solo si > 0)
                  if (calificacion > 0)
                    Positioned(
                      bottom: 12,
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
                              Icons.star_rounded,
                              color: Color(0xFFFFC107),
                              size: 16,
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
                        fontSize: 19,
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Icon(
                          esRestaurante
                              ? Icons.restaurant_outlined
                              : Icons.explore_outlined,
                          size: 16,
                          color: AppColors.primary(context),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          esRestaurante ? 'Ver restaurante' : 'Ver destino',
                          style: TextStyle(
                            color: AppColors.primary(context),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: AppColors.primary(context),
                        ),
                      ],
                    ),
                    if (tieneCoordenadas) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: PressScale(
                          scaleAbajo: 0.97,
                          onTap: () => _trazarRuta(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1565C0),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.directions_outlined,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Trazar ruta',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String texto;
  final Color fondo;
  final Color color;

  const _Chip({
    required this.icon,
    required this.texto,
    required this.fondo,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 4),
          Text(
            texto,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
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
      height: 190,
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
