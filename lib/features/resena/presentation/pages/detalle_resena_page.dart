import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../domain/entities/DestinoResenaEntity.dart';
import '../providers/ResenasProvider.dart';
import '../widgets/resena_card.dart';
import '../widgets/star_rating.dart';
import '../../../home/presentation/widgets/home_app_bar.dart';
import './escribir_resena_page.dart';

class DetalleResenaPage extends StatefulWidget {
  final DestinoResenaEntity destino;

  const DetalleResenaPage({super.key, required this.destino});

  @override
  State<DetalleResenaPage> createState() => _DetalleResenaPageState();
}

class _DetalleResenaPageState extends State<DetalleResenaPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargar());
  }

  void _cargar() {
    context.read<ResenasProvider>().cargarResenas(
      targetType: widget.destino.targetType,
      targetId: widget.destino.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✓ MediaQuery: adapta paddings/tamaños al tamaño real de pantalla.
    final size = MediaQuery.sizeOf(context);
    final destino = widget.destino;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: const HomeAppBar(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final publicado = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => EscribirResenaPage(destino: destino),
            ),
          );
          if (publicado == true && mounted) _cargar();
        },
        backgroundColor: const Color(0xFF2E7D32),
        icon: const Icon(Icons.edit, color: Colors.white),
        label: const Text(
          'Escribir Reseña',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        children: [
          // ✓ AspectRatio: mantiene proporción de la imagen hero.
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
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.6),
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
                          // Flexible: evita overflow si la ubicación es larga.
                          Flexible(
                            child: Text(
                              destino.ubicacion,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
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

          // ── Resumen de calificación (dinámico, vía ResenasProvider) ────
          Consumer<ResenasProvider>(
            builder: (context, provider, child) {
              if (provider.status == ResenasStatus.loading) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
                  ),
                );
              }

              if (provider.status == ResenasStatus.error) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: _ErrorResenas(
                    message:
                        provider.errorMessage ??
                        'No fue posible obtener las reseñas',
                    onRetry: _cargar,
                  ),
                );
              }

              final desglose = provider.desgloseEstrellas;

              return Container(
                color: Colors.white,
                padding: const EdgeInsets.all(20),
                child: FractionallySizedBox(
                  // ✓ FractionallySizedBox: ocupa el 100% del ancho.
                  widthFactor: 1.0,
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Text(
                            provider.promedioCalificacion.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B1B1B),
                              height: 1,
                            ),
                          ),
                          StarRating(
                            rating: provider.promedioCalificacion,
                            size: 20,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${provider.resenas.length} RESEÑAS',
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
                      // Expanded: la columna de barras llena el resto.
                      Expanded(
                        child: Column(
                          children: [5, 4, 3, 2, 1].map((estrellas) {
                            final valor = desglose[estrellas] ?? 0;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: [
                                  Text(
                                    '$estrellas',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF888888),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: valor,
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
                                    '${(valor * 100).toInt()}%',
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
              );
            },
          ),

          const SizedBox(height: 8),

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
              ],
            ),
          ),

          Consumer<ResenasProvider>(
            builder: (context, provider, child) {
              if (provider.status != ResenasStatus.success) {
                return const SizedBox.shrink();
              }
              if (provider.resenas.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      'Aún no hay reseñas. ¡Sé el primero en escribir una!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF888888)),
                    ),
                  ),
                );
              }
              return Column(
                children: provider.resenas
                    .map(
                      (resena) => Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        child: ResenaCard(resena: resena),
                      ),
                    )
                    .toList(),
              );
            },
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _ErrorResenas extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorResenas({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFCDD2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 36,
            color: Color(0xFFD32F2F),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Reintentar'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }
}
