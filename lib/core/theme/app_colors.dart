import 'package:flutter/material.dart';

/// Acceso rápido a colores semánticos del tema activo.
/// Uso: AppColors.surface(context), AppColors.textPrimary(context), etc.
class AppColors {
  AppColors._();

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  // Fondos
  static Color background(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;

  static Color surface(BuildContext context) =>
      Theme.of(context).colorScheme.surface;

  static Color surfaceLowest(BuildContext context) =>
      Theme.of(context).colorScheme.surfaceContainerLowest;

  static Color surfaceLow(BuildContext context) =>
      Theme.of(context).colorScheme.surfaceContainerLow;

  static Color surfaceContainer(BuildContext context) =>
      Theme.of(context).colorScheme.surfaceContainer;

  // Textos
  static Color textPrimary(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  static Color textSecondary(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55);

  static Color textHint(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35);

  // Color principal (verde)
  static Color primary(BuildContext context) =>
      Theme.of(context).colorScheme.primary;

  static Color primaryContainer(BuildContext context) =>
      Theme.of(context).colorScheme.primaryContainer;

  static Color onPrimary(BuildContext context) =>
      Theme.of(context).colorScheme.onPrimary;

  static Color onPrimaryContainer(BuildContext context) =>
      Theme.of(context).colorScheme.onPrimaryContainer;

  // Color secundario
  static Color secondary(BuildContext context) =>
      Theme.of(context).colorScheme.secondary;

  static Color onSecondary(BuildContext context) =>
      Theme.of(context).colorScheme.onSecondary;

  static Color secondaryContainer(BuildContext context) =>
      Theme.of(context).colorScheme.secondaryContainer;

  static Color onSecondaryContainer(BuildContext context) =>
      Theme.of(context).colorScheme.onSecondaryContainer;

  // Bordes / divisores
  static Color border(BuildContext context) =>
      Theme.of(context).colorScheme.outline;

  static Color borderSubtle(BuildContext context) =>
      Theme.of(context).colorScheme.outlineVariant;

  // Error
  static Color error(BuildContext context) =>
      Theme.of(context).colorScheme.error;

  static Color onError(BuildContext context) =>
      Theme.of(context).colorScheme.onError;

  static Color errorContainer(BuildContext context) =>
      Theme.of(context).colorScheme.errorContainer;

  static Color onErrorContainer(BuildContext context) =>
      Theme.of(context).colorScheme.onErrorContainer;

  // Overlay/scrim — para fondos oscurecidos sobre imágenes (siempre
  // negro semitransparente, deliberadamente igual en ambos temas: no
  // vive "sobre" el fondo temático sino sobre una foto).
  static Color scrim(BuildContext context) =>
      Theme.of(context).colorScheme.scrim;

  // ── Acento morado ("Gratis", categoría "Talleres", etc.) ──────────────
  // El ColorScheme de la app no define un slot morado — pero el color se
  // repetía hardcodeado (y fijo en modo claro) en 5 archivos distintos.
  // Se centraliza aquí, con variante oscura para que no quede un parche
  // claro sobre el tema oscuro.
  static Color accentPurple(BuildContext context) =>
      isDark(context) ? const Color(0xFFD1B3FF) : const Color(0xFF6A1B9A);

  static Color accentPurpleContainer(BuildContext context) =>
      isDark(context) ? const Color(0xFF3B2A5A) : const Color(0xFFEDE7F6);
}
