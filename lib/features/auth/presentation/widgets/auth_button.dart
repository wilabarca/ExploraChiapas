import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/press_scale.dart';

/// Botón de Welcome (Registro/Inicio de sesión). Solo se usa en esta
/// pantalla — el efecto de presión es un escalado sutil (`PressScale`,
/// mismo patrón ya reutilizado en el resto de la app) en vez del ripple
/// por defecto de `ElevatedButton`, para una sensación más "premium" y
/// consistente con el rediseño.
class AuthButton extends StatelessWidget {
  final String text;
  final bool isPrimary;
  final VoidCallback onPressed;

  const AuthButton({
    super.key,
    required this.text,
    required this.isPrimary,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onPressed,
      scaleAbajo: 0.97,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 54),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary(context) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: isPrimary
              ? null
              : Border.all(
                  color: AppColors.primary(context).withValues(alpha: 0.4),
                  width: 1.4,
                ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isPrimary
                    ? AppColors.onPrimary(context)
                    : AppColors.primary(context),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            if (isPrimary) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_rounded,
                size: 18,
                color: AppColors.onPrimary(context),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
