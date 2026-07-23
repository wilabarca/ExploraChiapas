import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/DestinoResenaEntity.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../widgets/destino_resena_card.dart';
import '../../../home/presentation/widgets/home_app_bar.dart';
import '../../../destinos/presentation/providers/destinos_provider.dart';
import '../../../destinos/domain/entities/destino.dart';
import '../../../categorias/presentation/providers/categorias_provider.dart';
import '../pages/detalle_resena_page.dart';

/// ⚠️ La API de reseñas no da un conteo agregado por destino, y
/// `GET /destinations` hoy puede devolver una lista vacía si todavía no
/// hay destinos cargados en producción — por eso el estado "sin
/// destinos" es real, no un bug: se maneja con su propio diseño en vez
/// de un mensaje genérico.
class HomeResenasPage extends StatefulWidget {
  const HomeResenasPage({super.key});

  @override
  State<HomeResenasPage> createState() => _HomeResenasPageState();
}

class _HomeResenasPageState extends State<HomeResenasPage> {
  String? _categoriaSeleccionada; // null = "Todas"

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final destinoProvider = context.read<DestinoProvider>();
      if (destinoProvider.listStatus == DestinoStatus.idle) {
        destinoProvider.loadDestinos(limit: 20);
      }
      context.read<CategoriasProvider>().cargarSiHaceFalta();
    });
  }

  DestinoResenaEntity _mapDestino(Destino destino, String categoriaNombre) {
    return DestinoResenaEntity(
      id: destino.id,
      nombre: destino.name,
      ubicacion: categoriaNombre,
      imageUrl: (destino.imageUrl != null && destino.imageUrl!.isNotEmpty)
          ? destino.imageUrl!
          : 'https://images.unsplash.com/photo-1518638150340-f706e86654de?w=800&q=80',
      calificacion: destino.averageRating,
      // La API de reseñas no da un conteo agregado por destino todavía.
      totalResenas: destino.totalReviews,
      tipo: categoriaNombre,
      esPopular: destino.averageRating >= 4.7,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: const HomeAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: AppColors.surface(context),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reseñas',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Descubre experiencias reales de otros viajeros',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary(context)),
                ),
                const SizedBox(height: 14),
                Consumer<CategoriasProvider>(
                  builder: (context, categoriasProvider, __) {
                    final categorias = categoriasProvider.categoriasDeDestinos;
                    return SizedBox(
                      height: 36,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _ChipCategoria(
                            texto: 'Todas',
                            activo: _categoriaSeleccionada == null,
                            onTap: () =>
                                setState(() => _categoriaSeleccionada = null),
                          ),
                          for (final categoria in categorias) ...[
                            const SizedBox(width: 8),
                            _ChipCategoria(
                              texto: categoria.nombre,
                              activo: _categoriaSeleccionada == categoria.id,
                              onTap: () => setState(
                                () => _categoriaSeleccionada = categoria.id,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Expanded: el grid ocupa todo el espacio vertical restante.
          Expanded(
            child: Consumer2<DestinoProvider, CategoriasProvider>(
              builder: (context, destinoProvider, categoriasProvider, child) {
                if (destinoProvider.listStatus == DestinoStatus.loading) {
                  return const SkeletonList(count: 4);
                }

                if (destinoProvider.listStatus == DestinoStatus.error) {
                  return _EstadoError(
                    mensaje: destinoProvider.listErrorMessage ??
                        'No fue posible obtener los destinos',
                    onReintentar: () =>
                        destinoProvider.loadDestinos(limit: 20),
                  );
                }

                List<Destino> destinosFiltrados = destinoProvider.destinos;
                if (_categoriaSeleccionada != null) {
                  destinosFiltrados = destinosFiltrados
                      .where((d) => d.categoryId == _categoriaSeleccionada)
                      .toList();
                }

                if (destinosFiltrados.isEmpty) {
                  return _EstadoVacio(
                    filtrando: _categoriaSeleccionada != null,
                    onVerTodas: () =>
                        setState(() => _categoriaSeleccionada = null),
                  );
                }

                // ✓ GridView.builder: reorganiza las tarjetas en 2 columnas
                // y las recicla eficientemente al hacer scroll.
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio:
                        (size.width / 2 - 22) / (size.height * 0.38),
                  ),
                  itemCount: destinosFiltrados.length,
                  itemBuilder: (context, i) {
                    final destinoOriginal = destinosFiltrados[i];
                    final categoriaNombre = categoriasProvider.nombrePorId(
                      destinoOriginal.categoryId,
                    );
                    final destino =
                        _mapDestino(destinoOriginal, categoriaNombre);
                    return DestinoResenaCard(
                      destino: destino,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetalleResenaPage(destino: destino),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipCategoria extends StatelessWidget {
  final String texto;
  final bool activo;
  final VoidCallback onTap;

  const _ChipCategoria({
    required this.texto,
    required this.activo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: activo ? AppColors.primary(context) : AppColors.background(context),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: activo ? AppColors.primary(context) : AppColors.border(context),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          texto,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: activo ? Colors.white : AppColors.textSecondary(context),
          ),
        ),
      ),
    );
  }
}

class _EstadoVacio extends StatelessWidget {
  final bool filtrando;
  final VoidCallback onVerTodas;

  const _EstadoVacio({required this.filtrando, required this.onVerTodas});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              filtrando ? Icons.filter_alt_off_outlined : Icons.explore_off_outlined,
              size: 52,
              color: AppColors.textHint(context),
            ),
            const SizedBox(height: 14),
            Text(
              filtrando
                  ? 'Sin destinos en esta categoría'
                  : 'Todavía no hay destinos para reseñar',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              filtrando
                  ? 'Prueba con otra categoría o mira todos los destinos disponibles.'
                  : 'En cuanto haya destinos publicados en ExploraChiapas, aparecerán aquí para que compartas tu experiencia.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary(context)),
            ),
            if (filtrando) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onVerTodas,
                icon: const Icon(Icons.apps, size: 18),
                label: const Text('Ver todas las categorías'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary(context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EstadoError extends StatelessWidget {
  final String mensaje;
  final VoidCallback onReintentar;

  const _EstadoError({required this.mensaje, required this.onReintentar});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_outlined, size: 48, color: AppColors.error(context)),
            const SizedBox(height: 12),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary(context)),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onReintentar,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Reintentar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
