import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../home/presentation/widgets/home_app_bar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../home/presentation/widgets/custom_bottom_nav_bar.dart';
import '../../domain/entities/promocion.dart';
import '../providers/promociones_provider.dart';
import '../widgets/promocion_card.dart';
import '../widgets/promociones_filtro_bar.dart';

class PromocionesPage extends StatefulWidget {
  /// Si se provee, la lista se filtra desde el backend por este negocio.
  final String? negocioId;

  const PromocionesPage({super.key, this.negocioId});

  @override
  State<PromocionesPage> createState() => _PromocionesPageState();
}

class _PromocionesPageState extends State<PromocionesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<PromocionesProvider>();
      if (provider.status == PromocionesStatus.idle) {
        provider.cargarPromociones(negocioId: widget.negocioId);
      }
    });
  }

  void _onNavTap(BottomNavTab tab) {
    switch (tab) {
      case BottomNavTab.explorar:
        Navigator.popUntil(context, (route) => route.isFirst);
        break;
      case BottomNavTab.mapa:
        Navigator.pushNamed(context, '/mapa');
        break;
      case BottomNavTab.favoritos:
        Navigator.pushNamed(context, '/favoritos');
        break;
      case BottomNavTab.resenas:
        Navigator.pushNamed(context, '/resenas');
        break;
      case BottomNavTab.perfil:
        Navigator.pushNamed(context, '/perfil');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ MediaQuery para decidir el layout responsivo.
    final mq = MediaQuery.of(context);
    final screenW = mq.size.width;
    final isTablet = screenW >= 600;
    final isLarge = screenW >= 900;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: const HomeAppBar(),
      body: Center(
        // ConstrainedBox: evita que el contenido se estire de más en
        // pantallas grandes.
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  isTablet ? (isLarge ? 40 : 24) : 20,
                  16,
                  isTablet ? (isLarge ? 40 : 24) : 20,
                  8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Promociones',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Descuentos y ofertas activas en Chiapas',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Consumer<PromocionesProvider>(
                      builder: (context, provider, _) {
                        return PromocionesFiltroBar(
                          filtroActivo: provider.filtro,
                          onFiltroChanged: provider.cambiarFiltro,
                        );
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Consumer<PromocionesProvider>(
                      builder: (context, provider, _) {
                        if (provider.status == PromocionesStatus.loading) {
                          return const SkeletonList(count: 4);
                        }

                        if (provider.status == PromocionesStatus.error) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: _ErrorPromociones(
                                message:
                                    provider.errorMessage ??
                                    'No se pudieron cargar las promociones',
                                onRetry: () => provider.cargarPromociones(
                                  negocioId: widget.negocioId,
                                ),
                              ),
                            ),
                          );
                        }

                        final promociones = provider.promocionesFiltradas;

                        if (promociones.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.local_offer_outlined,
                                  size: 64,
                                  color: AppColors.textHint(context),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Sin promociones en esta categoría',
                                  style: TextStyle(
                                    color: AppColors.textSecondary(context),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        if (isTablet) {
                          return GridView.builder(
                            padding: const EdgeInsets.all(20),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: isLarge ? 3 : 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.82,
                                ),
                            itemCount: promociones.length,
                            itemBuilder: (context, i) =>
                                PromocionCard(promocion: promociones[i]),
                          );
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.all(20),
                          itemCount: promociones.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 14),
                          itemBuilder: (context, i) =>
                              PromocionCard(promocion: promociones[i]),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        navItems: AppBottomNav.items,
        currentTab: BottomNavTab.explorar,
        onTap: _onNavTap,
      ),
    );
  }
}

class _ErrorPromociones extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorPromociones({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.cloud_off_outlined,
          size: 48,
          color: AppColors.error(context),
        ),
        const SizedBox(height: 12),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary(context),
          ),
        ),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('Reintentar'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary(context),
          ),
        ),
      ],
    );
  }
}
