import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/favoritos_provider.dart';
import '../widgets/favorito_card.dart';
import '../../domain/entities/favorito.dart';
import '../../../home/presentation/widgets/home_app_bar.dart';
import '../../../destinos/presentation/providers/destinos_provider.dart';

/// ⚠️ La API de favoritos solo da targetType/targetId/addedAt. Para
/// destinos, cruzamos contra `DestinoProvider.destinos` (si ya está
/// cargado) para mostrar nombre/calificación reales. Para negocios no
/// hay todavía un NegocioProvider conectado a la UI, así que se muestran
/// con una tarjeta genérica — dime si quieres que construyamos ese
/// provider para completar esto.
class FavoritosPage extends StatefulWidget {
  const FavoritosPage({super.key});

  @override
  State<FavoritosPage> createState() => _FavoritosPageState();
}

class _FavoritosPageState extends State<FavoritosPage> {
  String _filtroActivo = 'General';
  final _filtros = ['General', 'Destinos', 'Negocios'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritosProvider>().cargarFavoritos();
    });
  }

  List<Favorito> _filtrar(FavoritosProvider provider) {
    switch (_filtroActivo) {
      case 'Destinos':
        return provider.destinosFavoritos;
      case 'Negocios':
        return provider.negociosFavoritos;
      default:
        return provider.favoritos;
    }
  }

  /// Busca el destino real en DestinoProvider por id, si existe.
  dynamic _buscarDestino(BuildContext context, String targetId) {
    final destinos = context.read<DestinoProvider>().destinos;
    try {
      return destinos.firstWhere((d) => d.id == targetId);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✓ MediaQuery.sizeOf: tamaños proporcionales sin rebuilds extra.
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.width >= 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: const HomeAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Favoritos',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B1B1B),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tus destinos y negocios guardados',
                  style: TextStyle(fontSize: 13, color: Color(0xFF888888)),
                ),
                const SizedBox(height: 14),
                // ✓ Wrap: los chips fluyen si no caben en el ancho.
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _filtros.map((f) {
                    final activo = f == _filtroActivo;
                    return GestureDetector(
                      onTap: () => setState(() => _filtroActivo = f),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color:
                              activo ? const Color(0xFF2E7D32) : Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: activo
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFFDDDDDD),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          f,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: activo
                                ? Colors.white
                                : const Color(0xFF555555),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Expanded: la lista ocupa el resto del alto disponible.
          Expanded(
            child: Consumer<FavoritosProvider>(
              builder: (context, provider, child) {
                if (provider.status == FavoritosStatus.loading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF2E7D32),
                    ),
                  );
                }

                if (provider.status == FavoritosStatus.error) {
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.cloud_off_outlined,
                              size: 36, color: Color(0xFFD32F2F)),
                          const SizedBox(height: 10),
                          Text(
                            provider.errorMessage ??
                                'No fue posible obtener tus favoritos',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Color(0xFF666666)),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () => provider.cargarFavoritos(),
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text('Reintentar'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final items = _filtrar(provider);

                if (items.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite_border,
                            size: 48, color: Color(0xFFCCCCCC)),
                        SizedBox(height: 12),
                        Text(
                          'Aún no tienes favoritos aquí',
                          style: TextStyle(color: Color(0xFF888888)),
                        ),
                      ],
                    ),
                  );
                }

                // ✓ GridView.builder: 2 columnas en móvil, 3 en tablet
                // (LayoutBuilder + MediaQuery combinados).
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = isTablet ? 3 : 2;
                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.78,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, i) {
                        final favorito = items[i];
                        final esDestino = favorito.targetType ==
                            FavoritoTargetType.destination;

                        final destinoReal = esDestino
                            ? _buscarDestino(context, favorito.targetId)
                            : null;

                        return FavoritoCard(
                          targetType: favorito.targetType,
                          targetId: favorito.targetId,
                          nombre: destinoReal?.name as String?,
                          calificacion:
                              (destinoReal?.averageRating as num?)
                                  ?.toDouble(),
                          procesando: provider.estaProcesando(
                            favorito.targetType,
                            favorito.targetId,
                          ),
                          onQuitar: () async {
                            final ok = await provider.quitarFavorito(
                              targetType: favorito.targetType,
                              targetId: favorito.targetId,
                            );
                            if (!ok && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    provider.errorMessage ??
                                        'No se pudo quitar de favoritos',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                        );
                      },
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