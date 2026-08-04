import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/resena_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/profanity_filter.dart';
import '../providers/ResenasProvider.dart';
import '../utils/resena_display_utils.dart';
import 'resena_avatar.dart';
import 'star_rating.dart';

/// `GET /reviews` devuelve `userName`/`userImageUrl` embebidos — se
/// muestra el nombre real del autor (respaldo "Viajero ExploraChiapas"
/// solo para reseñas antiguas sin ese campo), y "Tú" cuando la reseña es
/// del usuario actual.
class ResenaCard extends StatelessWidget {
  final Resena resena;

  const ResenaCard({super.key, required this.resena});

  @override
  Widget build(BuildContext context) {
    final miId = context.watch<AuthProvider>().usuario?.id;
    final esMia = miId != null && miId == resena.userId;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ResenaAvatar(resena: resena, radius: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            esMia
                                ? 'Tú'
                                : (resena.userName ?? 'Viajero ExploraChiapas'),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        StarRating(rating: resena.rating.toDouble(), size: 13),
                        const SizedBox(width: 6),
                        Text(
                          '· ${ResenaDisplayUtils.tiempoRelativo(resena.createdAt)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textHint(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (esMia)
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    size: 18,
                    color: AppColors.textHint(context),
                  ),
                  onSelected: (opcion) {
                    if (opcion == 'editar') {
                      _mostrarEditarResena(context, resena);
                    } else if (opcion == 'eliminar') {
                      _confirmarEliminar(context, resena.id);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'editar',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18),
                          SizedBox(width: 10),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'eliminar',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: Colors.red,
                          ),
                          SizedBox(width: 10),
                          Text('Eliminar', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (resena.comment != null && resena.comment!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              resena.comment!,
              style: TextStyle(
                fontSize: 13.5,
                color: AppColors.textSecondary(context),
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _mostrarEditarResena(BuildContext context, Resena resena) {
    final resenasProvider = context.read<ResenasProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: resenasProvider,
        child: _EditarResenaSheet(resena: resena),
      ),
    );
  }

  void _confirmarEliminar(BuildContext context, String resenaId) {
    final resenasProvider = context.read<ResenasProvider>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('¿Eliminar reseña?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final exito = await resenasProvider.eliminarResena(resenaId);
              if (!ctx.mounted) return;
              if (exito) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(
                    content: const Text('Reseña eliminada.'),
                    backgroundColor: AppColors.primary(ctx),
                  ),
                );
              } else {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(
                    content: Text(
                      resenasProvider.edicionError ??
                          'No fue posible realizar la operación. '
                              'Inténtalo nuevamente.',
                    ),
                    backgroundColor: AppColors.error(ctx),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _EditarResenaSheet extends StatefulWidget {
  final Resena resena;

  const _EditarResenaSheet({required this.resena});

  @override
  State<_EditarResenaSheet> createState() => _EditarResenaSheetState();
}

class _EditarResenaSheetState extends State<_EditarResenaSheet> {
  late double _rating = widget.resena.rating.toDouble();
  late final _comentarioCtrl = TextEditingController(
    text: widget.resena.comment ?? '',
  );

  @override
  void dispose() {
    _comentarioCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    // Al crear una reseña ya se bloqueaba el lenguaje inapropiado
    // (`escribir_resena_page.dart`), pero al EDITARLA no había ningún
    // filtro — un usuario podía publicar un comentario limpio y luego
    // cambiarlo por uno con groserías sin que nada lo detectara.
    if (ProfanityFilter.contiene(_comentarioCtrl.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Tu comentario contiene lenguaje inapropiado, revísalo.',
          ),
          backgroundColor: AppColors.error(context),
        ),
      );
      return;
    }

    final provider = context.read<ResenasProvider>();
    final exito = await provider.editarResena(
      id: widget.resena.id,
      rating: _rating.round(),
      comment: _comentarioCtrl.text.trim().isEmpty
          ? null
          : _comentarioCtrl.text.trim(),
    );
    if (!mounted) return;
    if (exito) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Calificación actualizada.'),
          backgroundColor: AppColors.primary(context),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.edicionError ??
                'No fue posible realizar la operación. Inténtalo nuevamente.',
          ),
          backgroundColor: AppColors.error(context),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cargando =
        context.watch<ResenasProvider>().edicionStatus == EdicionStatus.loading;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: AppColors.borderSubtle(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Editar reseña',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: StarRating(
                rating: _rating,
                size: 32,
                interactive: true,
                onRatingChanged: (v) => setState(() => _rating = v),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _comentarioCtrl,
              maxLines: 3,
              maxLength: 300,
              decoration: InputDecoration(
                hintText: 'Comparte tu experiencia (opcional)',
                filled: true,
                fillColor: AppColors.background(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: cargando ? null : _guardar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary(context),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: cargando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Guardar cambios',
                        style: TextStyle(
                          color: AppColors.onPrimary(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
