import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../resena/domain/entities/DestinoResenaEntity.dart';
import '../../../resena/presentation/pages/escribir_resena_page.dart';
import '../../../resena/presentation/providers/ResenasProvider.dart';
import '../../../resena/presentation/widgets/resena_card.dart';

class LugarDetailPage extends StatefulWidget {
  final String id;
  final String nombre;
  final String categoria;
  final double calificacion;
  final String imageUrl;
  final String? descripcion;
  final int totalResenas;

  const LugarDetailPage({
    super.key,
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.calificacion,
    required this.imageUrl,
    this.descripcion,
    this.totalResenas = 0,
  });

  @override
  State<LugarDetailPage> createState() => _LugarDetailPageState();
}

class _LugarDetailPageState extends State<LugarDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ResenasProvider>().cargarResenas(
            targetType: 'destination',
            targetId: widget.id,
          );
    });
  }

  void _irAEscribirResena() {
    final destino = DestinoResenaEntity(
      id: widget.id,
      nombre: widget.nombre,
      ubicacion: widget.categoria,
      imageUrl: widget.imageUrl,
      calificacion: widget.calificacion,
      totalResenas: widget.totalResenas,
      tipo: 'Naturaleza',
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EscribirResenaPage(destino: destino),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: widget.imageUrl.isNotEmpty ? 260 : 0,
            pinned: true,
            backgroundColor: AppColors.surface(context),
            leading: IconButton(
              icon: Icon(Icons.arrow_back,
                  color: AppColors.textPrimary(context)),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              widget.nombre,
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            flexibleSpace: widget.imageUrl.isNotEmpty
                ? FlexibleSpaceBar(
                    background: Image.network(
                      widget.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.primaryContainer(context),
                      ),
                    ),
                  )
                : null,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Categoría y calificación ──────────────────────────────
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer(context),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.categoria,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary(context),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.star,
                          size: 16, color: Color(0xFFFFC107)),
                      const SizedBox(width: 4),
                      Text(
                        widget.calificacion.toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '  (${widget.totalResenas} reseñas)',
                        style: TextStyle(
                            color: AppColors.textSecondary(context),
                            fontSize: 13),
                      ),
                    ],
                  ),

                  // ── Descripción ───────────────────────────────────────────
                  if (widget.descripcion != null &&
                      widget.descripcion!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Acerca de este lugar',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.descripcion!,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary(context),
                        height: 1.6,
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // ── Sección reseñas ───────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Reseñas',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _irAEscribirResena,
                        icon: Icon(Icons.rate_review_outlined,
                            size: 18, color: AppColors.primary(context)),
                        label: Text(
                          'Escribir reseña',
                          style: TextStyle(color: AppColors.primary(context)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Consumer<ResenasProvider>(
                    builder: (context, provider, _) {
                      if (provider.status == ResenasStatus.loading) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      if (provider.resenas.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              'Aún no hay reseñas. ¡Sé el primero!',
                              style: TextStyle(
                                  color: AppColors.textSecondary(context)),
                            ),
                          ),
                        );
                      }
                      return Column(
                        children: provider.resenas
                            .map((r) => ResenaCard(resena: r))
                            .toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: ElevatedButton.icon(
            onPressed: _irAEscribirResena,
            icon: const Icon(Icons.rate_review_outlined, color: Colors.white),
            label: const Text(
              'Dejar reseña',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary(context),
              elevation: 0,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ),
      ),
    );
  }
}
