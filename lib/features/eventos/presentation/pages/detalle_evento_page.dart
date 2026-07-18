import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/envento_entity.dart';

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
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // ── App Bar con imagen ───────────────────────────────────
          SliverAppBar(
            expandedHeight: size.height * 0.38,
            pinned: true,
            backgroundColor: Colors.white,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Color(0xFF1B1B1B),
                  size: 20,
                ),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.favorite_outline,
                    color: Color(0xFF1B1B1B),
                    size: 20,
                  ),
                  onPressed: () {},
                ),
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
                        Container(color: const Color(0xFFD8F5D8)),
                    errorWidget: (_, __, ___) => Container(
                      color: const Color(0xFFD8F5D8),
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
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B1B1B),
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

                  const Divider(color: Color(0xFFEEEEEE)),

                  const SizedBox(height: 20),

                  // Descripción
                  const Text(
                    'Acerca del evento',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B1B1B),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    evento.descripcion.isNotEmpty
                        ? evento.descripcion
                        : 'Este evento aún no tiene una descripción disponible.',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF555555),
                      height: 1.7,
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Divider(color: Color(0xFFEEEEEE)),

                  const SizedBox(height: 20),

                  // Organizado por
                  const Text(
                    'Organizado por',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B1B1B),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.business_outlined,
                          color: Color(0xFF2E7D32),
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
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1B1B1B),
                              ),
                            ),
                            const Text(
                              'Organizador verificado',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF2E7D32),
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
          color: Colors.white,
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
                icon: const Icon(
                  Icons.confirmation_number_outlined,
                  color: Colors.white,
                ),
                label: const Text(
                  'Asistir al evento',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: const Color(0xFF2E7D32)),
          const SizedBox(width: 6),
          // ✓ ConstrainedBox limita el ancho del label
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 160),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF555555),
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
