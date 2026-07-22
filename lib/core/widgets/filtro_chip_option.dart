import 'package:flutter/material.dart';

/// Una opción del selector de categorías tipo chips (Favoritos, Reseñas...).
///
/// [id] identifica la opción (id real de categoría del backend, o un
/// sentinel fijo como "general"). [label] es el texto visible.
class FiltroChipOption {
  final String id;
  final String label;
  final IconData icon;

  const FiltroChipOption({
    required this.id,
    required this.label,
    required this.icon,
  });
}
