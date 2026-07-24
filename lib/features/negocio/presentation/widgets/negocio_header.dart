import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../resena/presentation/providers/ResenasProvider.dart';
import '../../domain/entities/negocio.dart';

class NegocioHeader extends StatelessWidget {
  final Negocio negocio;
  final bool esFavorito;
  final VoidCallback onToggleFavorito;

  const NegocioHeader({
    super.key,
    required this.negocio,
    required this.esFavorito,
    required this.onToggleFavorito,
  });

  @override
  Widget build(BuildContext context) {
    // La galería real (`negocio.imagenes`) puede venir vacía si el
    // backend solo registró una foto para este negocio — en ese caso se
    // usa `imagenPrincipal` como único elemento, nunca se inventan más.
    final imagenes = negocio.imagenes.isNotEmpty
        ? negocio.imagenes
        : [negocio.imagenPrincipal];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: _GaleriaImagenes(imagenes: imagenes),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: _BotonFavorito(
                esFavorito: esFavorito,
                onTap: onToggleFavorito,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text(
                negocio.nombre,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ),
            if (negocio.verificado)
              Icon(Icons.verified, color: AppColors.primary(context), size: 20),
          ],
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Consumer<ResenasProvider>(
              builder: (context, resenasProvider, _) {
                // Mientras no haya reseñas cargadas en memoria (recién
                // entrando a la pantalla) se muestra el promedio que ya
                // trae el negocio; en cuanto `ResenasProvider` tiene la
                // lista real, el promedio se recalcula en el cliente y
                // se refleja al instante tras cada reseña nueva/editada/
                // eliminada, sin recargar la pantalla.
                final hayResenasCargadas =
                    resenasProvider.status == ResenasStatus.success;
                final promedio = hayResenasCargadas
                    ? resenasProvider.promedioCalificacion
                    : negocio.calificacionPromedio;
                final total = hayResenasCargadas
                    ? resenasProvider.resenas.length
                    : negocio.numeroResenas;

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      promedio.toStringAsFixed(1),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      ' ($total reseñas)',
                      style: TextStyle(color: AppColors.textHint(context)),
                    ),
                  ],
                );
              },
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer(context),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                negocio.tipoNegocioNombre,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary(context),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Galería de imágenes con scroll horizontal + indicadores ────────────────

class _GaleriaImagenes extends StatefulWidget {
  final List<String> imagenes;

  const _GaleriaImagenes({required this.imagenes});

  @override
  State<_GaleriaImagenes> createState() => _GaleriaImagenesState();
}

class _GaleriaImagenesState extends State<_GaleriaImagenes> {
  final _pageCtrl = PageController();
  int _pagina = 0;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imagenes = widget.imagenes
        .where((url) => url.trim().isNotEmpty)
        .toList();

    if (imagenes.isEmpty) {
      return Container(color: AppColors.primaryContainer(context));
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _pageCtrl,
          itemCount: imagenes.length,
          onPageChanged: (index) => setState(() => _pagina = index),
          itemBuilder: (context, index) {
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOut,
              builder: (context, opacidad, child) =>
                  Opacity(opacity: opacidad, child: child),
              child: Image.network(
                imagenes[index],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: AppColors.primaryContainer(context)),
              ),
            );
          },
        ),
        if (imagenes.length > 1)
          Positioned(
            bottom: 14,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(imagenes.length, (index) {
                final activo = index == _pagina;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: activo ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: activo
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}

// ── Botón de favorito con animación de "pop" al presionar ──────────────────

class _BotonFavorito extends StatefulWidget {
  final bool esFavorito;
  final VoidCallback onTap;

  const _BotonFavorito({required this.esFavorito, required this.onTap});

  @override
  State<_BotonFavorito> createState() => _BotonFavoritoState();
}

class _BotonFavoritoState extends State<_BotonFavorito> {
  bool _presionado = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => setState(() => _presionado = true),
      onPointerUp: (_) => setState(() => _presionado = false),
      onPointerCancel: (_) => setState(() => _presionado = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _presionado ? 0.85 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: Icon(
                widget.esFavorito ? Icons.favorite : Icons.favorite_border,
                key: ValueKey(widget.esFavorito),
                color: AppColors.primary(context),
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
