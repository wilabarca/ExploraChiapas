import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// Caja gris animada que simula contenido cargando.
class SkeletonBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12,
  });

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final baseColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE0E0E0);

    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}

// Skeleton para una tarjeta horizontal de destino/lugar
class SkeletonDestinoCard extends StatelessWidget {
  final double height;
  final double width;

  const SkeletonDestinoCard({
    super.key,
    this.height = 210,
    this.width = 180,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: width, height: height * 0.55, borderRadius: 14),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: width * 0.7, height: 13),
                const SizedBox(height: 8),
                SkeletonBox(width: width * 0.5, height: 11),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Fila horizontal de skeletons de tarjetas
class SkeletonCardRow extends StatelessWidget {
  final int count;
  final double cardHeight;
  final double cardWidth;

  const SkeletonCardRow({
    super.key,
    this.count = 3,
    this.cardHeight = 210,
    this.cardWidth = 180,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: cardHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: count,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, __) => SkeletonDestinoCard(
          height: cardHeight,
          width: cardWidth,
        ),
      ),
    );
  }
}

// Skeleton para una fila de lista (favoritos, reseñas, negocios)
class SkeletonListItem extends StatelessWidget {
  const SkeletonListItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          SkeletonBox(width: 64, height: 64, borderRadius: 12),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: double.infinity, height: 14),
                const SizedBox(height: 8),
                SkeletonBox(width: 160, height: 12),
                const SizedBox(height: 6),
                SkeletonBox(width: 100, height: 11),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Lista vertical de skeletons (negocios)
class SkeletonList extends StatelessWidget {
  final int count;

  const SkeletonList({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(count, (_) => const SkeletonListItem()),
    );
  }
}

// Skeleton para tarjeta de favorito (imagen arriba, texto abajo)
class SkeletonFavoritoCard extends StatelessWidget {
  const SkeletonFavoritoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: SkeletonBox(
              width: double.infinity,
              height: double.infinity,
              borderRadius: 13,
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SkeletonBox(width: double.infinity, height: 12),
                  const SizedBox(height: 8),
                  SkeletonBox(width: 80, height: 11),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Grid 2 columnas de skeletons (favoritos)
class SkeletonFavoritosGrid extends StatelessWidget {
  final int count;

  const SkeletonFavoritosGrid({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemCount: count,
      itemBuilder: (_, __) => const SkeletonFavoritoCard(),
    );
  }
}

// Skeleton para un item de evento (icono cuadrado + texto)
class SkeletonEventoItem extends StatelessWidget {
  const SkeletonEventoItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            SkeletonBox(width: 48, height: 48, borderRadius: 10),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: double.infinity, height: 13),
                  const SizedBox(height: 8),
                  SkeletonBox(width: 140, height: 11),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
