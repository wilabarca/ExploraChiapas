import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'home_promocion_card.dart';
import 'section_header.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../promociones/presentation/pages/detalle_promocion_page.dart';
import '../../../promociones/presentation/providers/promociones_provider.dart';

/// Carrusel de promociones vigentes para el Home. Se oculta por completo
/// si no hay ninguna activa. Comparte esta misma implementación entre
/// Home Turista y Home Local para no duplicar la lógica de carga,
/// estados y navegación al detalle.
///
/// El [PromocionesProvider] puede refrescarse en segundo plano (al
/// reanudar la app o volver al Home) sin que esta sección lo note salvo
/// por el resultado final: mientras haya datos ya visibles, un nuevo
/// `loading`/`error` NO reemplaza el carrusel — evita parpadeos y no
/// bloquea el Home con un estado de error.
class PromocionesActivasSection extends StatelessWidget {
  final String titulo;

  const PromocionesActivasSection({super.key, required this.titulo});

  void _irAPromociones(BuildContext context) {
    Navigator.pushNamed(context, '/promociones');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PromocionesProvider>(
      builder: (context, promocionesProvider, child) {
        final promociones = promocionesProvider.promocionesActivas;
        final status = promocionesProvider.status;
        final sinDatosAun = promociones.isEmpty;

        // Skeleton SOLO en la carga inicial (aún sin datos en memoria).
        // Un refresh silencioso de fondo con datos ya visibles jamás debe
        // mostrar este estado.
        if (status == PromocionesStatus.loading && sinDatosAun) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              height: 272,
              child: SkeletonCardRow(count: 2, cardHeight: 272, cardWidth: 240),
            ),
          );
        }

        // Si la carga inicial falla y no hay nada previo que mostrar, se
        // informa con un estado no bloqueante (con reintento) en vez de
        // ocultar la sección en silencio. Si ya había promociones
        // visibles, se conservan tal cual y el error se ignora aquí.
        if (status == PromocionesStatus.error && sinDatosAun) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _PromocionesErrorCard(
              message: promocionesProvider.errorMessage,
              onRetry: () => promocionesProvider.cargarPromociones(),
            ),
          );
        }

        // Sin promociones vigentes y sin error: la sección se oculta,
        // tal como espera el diseño actual del Home.
        if (sinDatosAun) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              icon: Icons.local_offer_outlined,
              titulo: titulo,
              mostrarVerTodos: true,
              onVerTodos: () => _irAPromociones(context),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 272,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: promociones.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final promo = promociones[index];
                  return HomePromocionCard(
                    promocion: promo,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetallePromocionPage(promocion: promo),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}

/// Tarjeta de error no bloqueante para cuando la carga inicial de
/// promociones falla y aún no hay nada que mostrar. Sigue el mismo
/// lenguaje visual que el resto de estados de error del Home.
class _PromocionesErrorCard extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;

  const _PromocionesErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LocaleProvider>().langCode;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.errorContainer(context)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: 36,
            color: AppColors.error(context),
          ),
          const SizedBox(height: 10),
          Text(
            message ?? AppStrings.tr('error_promociones', lang),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: Text(AppStrings.tr('reintentar', lang)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary(context),
            ),
          ),
        ],
      ),
    );
  }
}
