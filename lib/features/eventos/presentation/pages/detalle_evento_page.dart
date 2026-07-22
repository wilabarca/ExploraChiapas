import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/envento_entity.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../favoritos/domain/entities/favorito.dart';
import '../../../favoritos/presentation/providers/favoritos_provider.dart';

class DetalleEventoPage extends StatelessWidget {
  final EventoEntity evento;

  const DetalleEventoPage({super.key, required this.evento});

  Color get _categoriaColor {
    switch (evento.categoria) {
      case 'Gastronomía':
        return const Color(0xFFFF6F00);
      case 'Cultura':
        return const Color(0xFF6A1B9A);
      case 'Talleres':
        return const Color(0xFF1565C0);
      case 'Festivales':
        return const Color(0xFF00695C);
      default:
        return const Color(0xFF2E7D32);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✓ MediaQuery.sizeOf evita rebuilds innecesarios
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: AppColors.surface(context),
      body: CustomScrollView(
        slivers: [
          // ── App Bar con imagen ───────────────────────────────────
          SliverAppBar(
            expandedHeight: size.height * 0.38,
            pinned: true,
            backgroundColor: AppColors.surface(context),
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surface(context),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: AppColors.textPrimary(context),
                  size: 20,
                ),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surface(context),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.share_outlined,
                    color: AppColors.textPrimary(context),
                    size: 20,
                  ),
                  tooltip: 'Compartir',
                  onPressed: () {
                    Share.share(
                      '¡${evento.titulo} — ${evento.categoria}!\n${evento.descripcion}\n#ExploraChiapas',
                    );
                  },
                ),
              ),
              Consumer<FavoritosProvider>(
                builder: (context, favProvider, _) {
                  final esFav = favProvider.esFavorito(
                    FavoritoTargetType.event,
                    evento.id,
                  );
                  return Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surface(context),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        esFav ? Icons.favorite : Icons.favorite_outline,
                        color: esFav
                            ? Colors.red
                            : AppColors.textPrimary(context),
                        size: 20,
                      ),
                      onPressed: () {
                        if (favProvider.status == FavoritosStatus.idle) {
                          favProvider.cargarFavoritos();
                        }
                        favProvider.toggleFavorito(
                          targetType: FavoritoTargetType.event,
                          targetId: evento.id,
                        );
                      },
                    ),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: evento.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: AppColors.primaryContainer(context)),
                    errorWidget: (_, __, ___) => Container(
                      color: AppColors.primaryContainer(context),
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                  // Gradiente inferior
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                        stops: const [0.6, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Contenido ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge categoría
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _categoriaColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      evento.categoria,
                      style: TextStyle(
                        fontSize: 13,
                        color: _categoriaColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Título
                  Text(
                    evento.titulo,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(context),
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Info cards ──────────────────────────────────
                  // ✓ Wrap para que fluyan si no caben en una línea
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _InfoChip(
                        icon: Icons.calendar_today_outlined,
                        label: evento.fechaFormateada,
                      ),
                      _InfoChip(
                        icon: Icons.location_on_outlined,
                        label: evento.ubicacion,
                      ),
                      // ✅ Usa el getter fechaFinFormateada — sin
                      // instanciar un EventoEntity temporal.
                      if (evento.fechaFinFormateada != null)
                        _InfoChip(
                          icon: Icons.event_available_outlined,
                          label: 'Hasta ${evento.fechaFinFormateada}',
                        ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Divider(color: AppColors.borderSubtle(context)),

                  const SizedBox(height: 20),

                  // Descripción
                  Text(
                    'Acerca del evento',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(context),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    evento.descripcion.isNotEmpty
                        ? evento.descripcion
                        : 'Este evento aún no tiene una descripción disponible.',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary(context),
                      height: 1.7,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Divider(color: AppColors.borderSubtle(context)),

                  const SizedBox(height: 20),

                  // Organizado por
                  Text(
                    'Organizado por',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(context),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer(context),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.business_outlined,
                          color: AppColors.primary(context),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Expanded: evita overflow si creadoPor es largo.
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              evento.creadoPor,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary(context),
                              ),
                            ),
                            Text(
                              'Organizador verificado',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primary(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Botón flotante ─────────────────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          // ✓ FractionallySizedBox para botón proporcional
          child: FractionallySizedBox(
            widthFactor: 1.0,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 54),
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: registrarse al evento
                },
                icon: Icon(
                  Icons.confirmation_number_outlined,
                  color: AppColors.onPrimary(context),
                ),
                label: Text(
                  'Asistir al evento',
                  style: TextStyle(
                    color: AppColors.onPrimary(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary(context),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Widget reutilizable para info chips ─────────────────────────────────────
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.background(context),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: AppColors.primary(context)),
            const SizedBox(width: 6),
            // ✓ ConstrainedBox limita el ancho del label
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 160),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary(context),
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
