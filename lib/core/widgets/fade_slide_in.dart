import 'package:flutter/material.dart';

/// Envuelve cualquier widget con una entrada suave de fade + slide hacia
/// arriba. Reutilizable para dar a las secciones del Home (y de otras
/// pantallas) una sensación premium sin animaciones costosas: es un
/// simple `TweenAnimationBuilder` de un solo disparo, no un
/// `AnimationController` que haya que manejar manualmente.
///
/// [delay] permite escalonar varias secciones (efecto "staggered") solo
/// pasando valores crecientes — no afecta el rendimiento porque el
/// retraso se resuelve con un `Future.delayed` liviano, no con timers
/// activos de fondo.
class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final double offsetY;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 420),
    this.offsetY = 18,
  });

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _visible = true;
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) setState(() => _visible = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: _visible ? 1 : 0),
      duration: widget.duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, widget.offsetY * (1 - value)),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
