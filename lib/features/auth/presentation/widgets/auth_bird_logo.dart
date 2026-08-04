import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Logo circular oficial (nuevo branding "iconoapp"), usado en Login y
/// Registro. Sin halo de color detrás — solo el círculo blanco con el
/// ícono, más grande para que resalte.
class AuthBirdLogo extends StatelessWidget {
  final double size;

  const AuthBirdLogo({super.key, this.size = 190});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.15),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      // ClipOval evita que las esquinas del JPG (rectangular) se asomen
      // fuera del círculo blanco si su relación de aspecto no es 1:1 —
      // BoxFit.contain ya evita recortes/deformación del propio ícono.
      child: ClipOval(
        child: Image.asset('assets/images/iconoapp.jpg', fit: BoxFit.contain),
      ),
    );
  }
}
