import 'package:flutter/material.dart';

/// Envoltura reutilizable para el efecto de "escalado sutil al presionar"
/// usado en tarjetas de toda la app (`Listener` en vez de `GestureDetector`
/// para no chocar con gestos de scroll horizontal en carruseles).
class PressScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleAbajo;

  const PressScale({
    super.key,
    required this.child,
    this.onTap,
    this.scaleAbajo = 0.96,
  });

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
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
          scale: _presionado ? widget.scaleAbajo : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}
