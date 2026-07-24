import 'package:flutter/material.dart';

/// Helpers de presentación compartidos por cualquier tarjeta de reseña
/// (`ResenaCard`, `ResenaFeedCard`, etc.) — evita duplicar la lógica de
/// "color/iniciales por usuario" y "tiempo relativo" en cada tarjeta.
class ResenaDisplayUtils {
  ResenaDisplayUtils._();

  static const coloresAvatar = [
    Color(0xFF2E7D32),
    Color(0xFF1565C0),
    Color(0xFF6A1B9A),
    Color(0xFFEF6C00),
    Color(0xFFC2185B),
    Color(0xFF00838F),
  ];

  /// ⚠️ La API solo devuelve `userId`, no nombre ni foto del usuario
  /// (confirmado: los reviews nunca hacen JOIN contra la tabla
  /// `usuario`). Se distingue a cada autor con un color/iniciales
  /// consistentes derivados del propio `userId` en vez de un ícono
  /// genérico igual para todos.
  static Color colorPorUsuario(String userId) {
    final hash = userId.codeUnits.fold<int>(0, (acc, c) => acc + c);
    return coloresAvatar[hash % coloresAvatar.length];
  }

  static String iniciales(String userId) {
    final limpio = userId.replaceAll('-', '');
    return limpio.isEmpty ? '?' : limpio.substring(0, 2).toUpperCase();
  }

  static String tiempoRelativo(DateTime fecha) {
    final diferencia = DateTime.now().difference(fecha);

    if (diferencia.inMinutes < 1) return 'Justo ahora';
    if (diferencia.inMinutes < 60) return 'Hace ${diferencia.inMinutes} min';
    if (diferencia.inHours < 24) return 'Hace ${diferencia.inHours} h';
    if (diferencia.inDays == 1) return 'Ayer';
    if (diferencia.inDays < 7) return 'Hace ${diferencia.inDays} días';
    if (diferencia.inDays < 30) {
      return 'Hace ${(diferencia.inDays / 7).floor()} sem';
    }

    const meses = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];
    return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}';
  }
}
