import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/DestinoResenaEntity.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../widgets/destino_resena_card.dart';
import '../../../home/presentation/widgets/home_app_bar.dart';
import '../../../destinos/presentation/providers/destinos_provider.dart';
import '../pages/detalle_resena_page.dart';

/// ⚠️ IMPORTANTE: como eliminaste resenas_fake_data.dart, ahora esta
/// pantalla arma la lista de "lugares reseñables" a partir de
/// `DestinoProvider.destinos` (ya cargado por HomeTuristaPage).
///
/// LIMITACIÓN ACTUAL: tu app todavía no tiene un `NegocioProvider`
/// registrado en el DI (revisamos injector.config.dart antes y solo
/// existen los usecases de negocio, no un provider conectado a la UI).
/// Por eso, por ahora, quité los chips de "Restaurante"/"Hotel" — solo
/// muestro destinos turísticos. Si quieres esas categorías de vuelta,
/// dime y construyo el NegocioProvider igual que hicimos con Eventos.
class HomeResenasPage extends StatefulWidget {
  const HomeResenasPage({super.key});

  @override
  State<HomeResenasPage> createState() => _HomeResenasPageState();
}

class _HomeResenasPageState extends State<HomeResenasPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final destinoProvider = context.read<DestinoProvider>();
      if (destinoProvider.listStatus == DestinoStatus.idle) {
        destinoProvider.loadDestinos(limit: 20);
      }
    });
  }

  /// Convierte el modelo de DestinoProvider a la entidad que usan las
  /// tarjetas/páginas de reseñas.
  ///
  /// ⚠️ Verifica que tu modelo de destino realmente tenga `.id` — lo
  /// necesitamos para llamar a la API de reseñas (targetId). Si el campo
  /// se llama distinto, ajusta aquí.
  DestinoResenaEntity _mapDestino(dynamic destino) {
    return DestinoResenaEntity(
      id: destino.id as String,
      nombre: destino.name as String,
      // TODO: reemplaza cuando tu modelo de destino tenga ubicación real.
      ubicacion: 'Chiapas',
      // TODO: reemplaza cuando tu modelo de destino exponga imageUrl real.
      imageUrl:
          'https://images.unsplash.com/photo-1518638150340-f706e86654de?w=800&q=80',
      calificacion: (destino.averageRating as num).toDouble(),
      // La API de reseñas no da un conteo agregado por destino todavía.
      totalResenas: 0,
      tipo: 'General',
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✓ MediaQuery.sizeOf evita rebuilds innecesarios.
    final size = MediaQuery.sizeOf(context);

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
              ],
            ),
          ),

          // Expanded: el grid ocupa todo el espacio vertical restante.
          Expanded(
            child: Consumer<DestinoProvider>(
              builder: (context, destinoProvider, child) {
                if (destinoProvider.listStatus == DestinoStatus.loading) {
                  return const SkeletonList(count: 4);
                }

                if (destinoProvider.listStatus == DestinoStatus.error) {
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        destinoProvider.listErrorMessage ??
                            'No fue posible obtener los destinos',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary(context)),
                      ),
                    ),
                  );
                }

                final destinos = destinoProvider.destinos
                    .map(_mapDestino)
                    .toList();

                if (destinos.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 48,
                          color: AppColors.textHint(context),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No hay destinos disponibles',
                          style: TextStyle(color: AppColors.textSecondary(context)),
                        ),
                      ],
                    ),
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
                  itemCount: destinos.length,
                  itemBuilder: (context, i) {
                    final destino = destinos[i];
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
