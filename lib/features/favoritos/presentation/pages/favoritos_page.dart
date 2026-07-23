import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/favoritos_provider.dart';
import '../widgets/favorito_card.dart';
import '../widgets/favorito_destino_card.dart';
import '../../domain/entities/favorito.dart';
import '../../../home/presentation/widgets/home_app_bar.dart';
import '../../../destinos/presentation/providers/destinos_provider.dart';
import '../../../destinos/presentation/pages/lugar_detail_page.dart';
import '../../../destinos/domain/entities/destino.dart';
import '../../../categorias/presentation/providers/categorias_provider.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/skeleton_loader.dart';

/// ⚠️ La API de favoritos solo da targetType/targetId/addedAt. Para
/// destinos, cruzamos contra `DestinoProvider.destinos` (si ya está
/// cargado, o lo cargamos aquí mismo) para mostrar nombre/imagen/
/// calificación/categoría reales. Para negocios no hay todavía un
/// NegocioProvider conectado a la UI, así que se muestran con una
/// tarjeta genérica.
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
      context.read<CategoriasProvider>().cargarSiHaceFalta();

      final destinoProvider = context.read<DestinoProvider>();
      if (!destinoProvider.hasDestinos) {
        destinoProvider.loadDestinos();
      }
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

  /// Busca el destino real en DestinoProvider por id, si ya se cargó.
  Destino? _buscarDestino(BuildContext context, String targetId) {
    final destinos = context.read<DestinoProvider>().destinos;
    try {
      return destinos.firstWhere((d) => d.id == targetId);
    } catch (_) {
      return null;
    }
  }

  /// Agrupa los favoritos de tipo destino por el nombre real de su
  /// categoría (traída del backend, no hardcodeada). Los favoritos cuyo
  /// destino todavía no se ha resuelto (no está en DestinoProvider) se
  /// omiten de momento — se completan solos cuando termine de cargar.
  Map<String, List<MapEntry<Favorito, Destino>>> _agruparPorCategoria(
    BuildContext context,
    List<Favorito> favoritosDestinos,
    CategoriasProvider categoriasProvider,
  ) {
    final agrupados = <String, List<MapEntry<Favorito, Destino>>>{};
    for (final favorito in favoritosDestinos) {
      final destino = _buscarDestino(context, favorito.targetId);
      if (destino == null) continue;
      final categoria = categoriasProvider.nombrePorId(destino.categoryId);
      agrupados.putIfAbsent(categoria, () => []).add(
            MapEntry(favorito, destino),
          );
    }
    return agrupados;
  }

  void _abrirDetalle(
    BuildContext context, {
    required Destino destino,
    required String categoriaNombre,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LugarDetailPage(
          id: destino.id,
          nombre: destino.name,
          categoria: categoriaNombre,
          calificacion: destino.averageRating,
          imageUrl: destino.imageUrl ?? '',
          descripcion: destino.description,
          totalResenas: destino.totalReviews,
        ),
      ),
    );
  }

  void _irAPlanificarRuta(BuildContext context) {
    Navigator.pushNamed(context, '/mapa');
  }

  Future<void> _quitarFavorito(
    BuildContext context,
    FavoritosProvider provider,
    String targetType,
    String targetId,
    String Function(String) s,
  ) async {
    final ok = await provider.quitarFavorito(
      targetType: targetType,
      targetId: targetId,
    );
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? s('error_quitar_favorito')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _labelFiltro(String filtro, String lang) {
    switch (filtro) {
      case 'Destinos': return AppStrings.tr('filtro_destinos', lang);
      case 'Negocios': return AppStrings.tr('filtro_negocios', lang);
      default:         return AppStrings.tr('filtro_general', lang);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.width >= 600;
    final lang = context.watch<LocaleProvider>().langCode;
    String s(String k) => AppStrings.tr(k, lang);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: const HomeAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: AppColors.surface(context),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s('favoritos_titulo'),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  s('favoritos_subtitulo'),
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary(context)),
                ),
                const SizedBox(height: 14),
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
                              activo ? AppColors.primary(context) : AppColors.surface(context),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: activo
                                ? AppColors.primary(context)
                                : AppColors.border(context),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          _labelFiltro(f, lang),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: activo
                                ? Colors.white
                                : AppColors.textSecondary(context),
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
            child: Consumer2<FavoritosProvider, CategoriasProvider>(
              builder: (context, provider, categoriasProvider, child) {
                if (provider.status == FavoritosStatus.loading) {
                  return const SkeletonFavoritosGrid(count: 4);
                }

                if (provider.status == FavoritosStatus.error) {
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_off_outlined,
                              size: 36, color: AppColors.error(context)),
                          const SizedBox(height: 10),
                          Text(
                            provider.errorMessage ?? s('error_favoritos'),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textSecondary(context)),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () => provider.cargarFavoritos(),
                            icon: const Icon(Icons.refresh, size: 18),
                            label: Text(s('reintentar')),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final items = _filtrar(provider);

                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite_border,
                            size: 48, color: AppColors.textHint(context)),
                        const SizedBox(height: 12),
                        Text(
                          s('sin_favoritos'),
                          style: TextStyle(color: AppColors.textSecondary(context)),
                        ),
                      ],
                    ),
                  );
                }

                if (_filtroActivo == 'Destinos') {
                  return _ListaDestinosPorCategoria(
                    agrupados: _agruparPorCategoria(
                      context,
                      items,
                      categoriasProvider,
                    ),
                    procesando: (targetId) =>
                        provider.estaProcesando(
                          FavoritoTargetType.destination,
                          targetId,
                        ),
                    onTap: (destino, categoriaNombre) => _abrirDetalle(
                      context,
                      destino: destino,
                      categoriaNombre: categoriaNombre,
                    ),
                    onQuitar: (targetId) => _quitarFavorito(
                      context,
                      provider,
                      FavoritoTargetType.destination,
                      targetId,
                      s,
                    ),
                    onPlanificarRuta: () => _irAPlanificarRuta(context),
                  );
                }

                // ✓ GridView.builder: 2 columnas en móvil, 3 en tablet
                // (LayoutBuilder + MediaQuery combinados). Se mantiene
                // para "General" y "Negocios".
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
                          nombre: destinoReal?.name,
                          imageUrl: destinoReal?.imageUrl,
                          calificacion: destinoReal?.averageRating,
                          procesando: provider.estaProcesando(
                            favorito.targetType,
                            favorito.targetId,
                          ),
                          onTap: destinoReal != null
                              ? () => _abrirDetalle(
                                    context,
                                    destino: destinoReal,
                                    categoriaNombre: categoriasProvider
                                        .nombrePorId(destinoReal.categoryId),
                                  )
                              : null,
                          onQuitar: () => _quitarFavorito(
                            context,
                            provider,
                            favorito.targetType,
                            favorito.targetId,
                            s,
                          ),
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

/// Lista de destinos favoritos agrupados por categoría real, con
/// encabezado de sección por cada una (estilo "Mis Favoritos").
class _ListaDestinosPorCategoria extends StatelessWidget {
  final Map<String, List<MapEntry<Favorito, Destino>>> agrupados;
  final bool Function(String targetId) procesando;
  final void Function(Destino destino, String categoriaNombre) onTap;
  final void Function(String targetId) onQuitar;
  final VoidCallback onPlanificarRuta;

  const _ListaDestinosPorCategoria({
    required this.agrupados,
    required this.procesando,
    required this.onTap,
    required this.onQuitar,
    required this.onPlanificarRuta,
  });

  @override
  Widget build(BuildContext context) {
    if (agrupados.isEmpty) {
      // Los favoritos existen en el servidor pero sus destinos aún no
      // se resolvieron localmente (DestinoProvider sigue cargando).
      return const Center(child: CircularProgressIndicator());
    }

    final categorias = agrupados.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: categorias.length,
      itemBuilder: (context, index) {
        final categoria = categorias[index];
        final favoritosDeCategoria = agrupados[categoria]!;

        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10, left: 2),
                child: Text(
                  categoria,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ),
              ...favoritosDeCategoria.map((entry) {
                final favorito = entry.key;
                final destino = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: FavoritoDestinoCard(
                    destino: destino,
                    categoriaNombre: categoria,
                    guardadoEl: favorito.createdAt,
                    procesandoFavorito: procesando(favorito.targetId),
                    onTap: () => onTap(destino, categoria),
                    onQuitarFavorito: () => onQuitar(favorito.targetId),
                    onPlanificarRuta: onPlanificarRuta,
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
