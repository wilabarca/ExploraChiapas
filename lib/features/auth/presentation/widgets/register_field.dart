import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';

/// Campo de texto reutilizable para formularios de auth (login/registro).
///
/// [label] y [errorText] son opcionales para no afectar a las pantallas
/// que ya usaban este widget sin ellos: si no se pasan, el campo se
/// comporta igual que antes, solo con colores adaptados al tema (antes
/// eran fijos y no se veían bien en modo oscuro).
class RegisterField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? label;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;

  const RegisterField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.label,
    this.errorText,
    this.onChanged,
    this.inputFormatters,
  });

  @override
  State<RegisterField> createState() => _RegisterFieldState();
}

class _RegisterFieldState extends State<RegisterField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;
    // El campo vive dentro de una tarjeta verde clara (ver
    // _FormularioLogin/_FormularioRegistro): rellenarlo del mismo verde
    // lo hacía casi invisible (verde sobre verde). Un gris neutro
    // contrasta contra la tarjeta y hace que el campo se note de
    // inmediato, sin dejar de sentirse parte de la misma tarjeta.
    final fillColor = hasError
        ? AppColors.errorContainer(context)
        : AppColors.surfaceContainer(context);
    final borderColor = hasError
        ? AppColors.error(context)
        : Colors.transparent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppColors.primary(context),
            ),
          ),
          const SizedBox(height: 6),
        ],
        // ConstrainedBox garantiza altura minima accesible para el campo
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 52),
          child: Container(
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor, width: 1.4),
            ),
            child: TextField(
              controller: widget.controller,
              obscureText: widget.isPassword ? _obscure : false,
              keyboardType: widget.keyboardType,
              inputFormatters: widget.inputFormatters,
              onChanged: widget.onChanged,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary(context),
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: TextStyle(color: AppColors.textHint(context)),
                prefixIcon: Icon(
                  widget.icon,
                  color: AppColors.primary(context),
                  size: 20,
                ),
                suffixIcon: widget.isPassword
                    ? IconButton(
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.primary(context),
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      )
                    : null,
                // Evita heredar el "filled: true" del InputDecorationTheme
                // global: aquí el fondo ya lo pinta el Container exterior
                // (fillColor / errorContainer con esquinas redondeadas); sin
                // esto, el TextField superpone su propio rectángulo de
                // esquinas cuadradas encima.
                filled: false,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              widget.errorText!,
              style: TextStyle(fontSize: 12, color: AppColors.error(context)),
            ),
          ),
        ],
      ],
    );
  }
}
