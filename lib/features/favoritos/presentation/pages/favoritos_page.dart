import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/favorito.dart';
import '../providers/favoritos_provider.dart';

class FavoritosPage extends StatefulWidget {
  const FavoritosPage({super.key});

  @override
  State<FavoritosPage> createState() => _FavoritosPageState();
}

class _FavoritosPageState extends State<FavoritosPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<FavoritosProvider>().cargarFavoritos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F8F8),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1B1B1B)),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Mis Favoritos',
            style: TextStyle(
              color: Color(0xFF1B1B1B),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: const TabBar(
            labelColor: Color(0xFF2E7D32),
            unselectedLabelColor: Color(0xFF999999),
            indicatorColor: Color(0xFF2E7D32),
            tabs: [
              Tab(text: 'Destinos'),
              Tab(text: 'Rutas'),
              Tab(text: 'Experiencias'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _TabFavoritos(
              targetType: 'destination',
              emptyLabel: 'Sin destinos guardados',
              emptySubLabel: 'Explora el mapa y guarda tus lugares favoritos',
              icono: Icons.location_on_outlined,
            ),
            _TabFavoritos(
              targetType: 'route',
              emptyLabel: 'Sin rutas guardadas',
              emptySubLabel: 'Planifica una ruta y guÃ¡rdala aquÃ­',
              icono: Icons.route_outlined,
            ),
            _TabFavoritos(
              targetType: 'experience',
              emptyLabel: 'Sin experiencias guardadas',
              emptySubLabel: 'Explora y guarda las que mÃ¡s te interesen',
              icono: Icons.explore_outlined,
            ),
          ],
        ),
      ),
    );
  }
}

class _TabFavoritos extends StatelessWidget {
  final String targetType;
  final String emptyLabel;
  final String emptySubLabel;
  final IconData icono;

  const _TabFavoritos({
    required this.targetType,
    required this.emptyLabel,
    required this.emptySubLabel,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritosProvider>(
      builder: (context, provider, _) {
        if (provider.status == FavoritosStatus.loading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
          );
        }

        if (provider.status == FavoritosStatus.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off_outlined,
                    size: 48, color: Color(0xFFCCCCCC)),
                const SizedBox(height: 12),
                Text(
                  provider.errorMessage ?? 'Error al cargar favoritos',
                  style: const TextStyle(fontSize: 14, color: Color(0xFF888888)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => provider.cargarFavoritos(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          );
        }

        final items = provider.favoritos
            .where((f) => f.targetType == targetType)
            .toList();

        if (items.isEmpty) {
          return _EstadoVacio(
            icono: icono,
            label: emptyLabel,
            subLabel: emptySubLabel,
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final f = items[i];
            return _FavoritoTile(
              favorito: f,
              icono: icono,
              onEliminar: () => provider.alternar(
                targetType: f.targetType,
                targetId: f.targetId,
              ),
            );
          },
        );
      },
    );
  }
}

class _FavoritoTile extends StatelessWidget {
  final Favorito favorito;
  final IconData icono;
  final VoidCallback onEliminar;

  const _FavoritoTile({
    required this.favorito,
    required this.icono,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icono, color: const Color(0xFF2E7D32), size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  favorito.targetId,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B1B1B),
                  ),
                ),
                if (favorito.addedAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Guardado el ${_formatFecha(favorito.addedAt!)}',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onEliminar,
            icon: const Icon(Icons.favorite, color: Colors.red, size: 22),
          ),
        ],
      ),
    );
  }

  String _formatFecha(DateTime fecha) {
    const meses = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
    ];
    return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}';
  }
}

class _EstadoVacio extends StatelessWidget {
  final IconData icono;
  final String label;
  final String subLabel;

  const _EstadoVacio({
    required this.icono,
    required this.label,
    required this.subLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icono, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(label, style: const TextStyle(fontSize: 16, color: Color(0xFF999999))),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              subLabel,
              style: const TextStyle(fontSize: 13, color: Color(0xFFBBBBBB)),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// end of file
