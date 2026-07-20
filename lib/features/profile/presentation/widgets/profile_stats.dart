import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ProfileStats extends StatelessWidget {
  final String rutasCreadas;
  final String favoritos;
  final String resenas;

  const ProfileStats({
    super.key,
    required this.rutasCreadas,
    required this.favoritos,
    required this.resenas,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = constraints.maxWidth * 0.025;
        return Row(
          children: [
            Expanded(
              child: _StatCard(valor: rutasCreadas, label: 'Rutas\ncreadas'),
            ),
            SizedBox(width: gap),
            Expanded(
              child: _StatCard(valor: favoritos, label: 'Favoritos'),
            ),
            SizedBox(width: gap),
            Expanded(
              child: _StatCard(valor: resenas, label: 'Reseñas'),
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String valor;
  final String label;

  const _StatCard({required this.valor, required this.label});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 80),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderSubtle(context)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(
              child: Text(
                valor,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary(context),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary(context),
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
