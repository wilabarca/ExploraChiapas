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

  // Bordes / divisores
  static Color border(BuildContext context) =>
      Theme.of(context).colorScheme.outline;

  static Color borderSubtle(BuildContext context) =>
      Theme.of(context).colorScheme.outlineVariant;

  // Error
  static Color error(BuildContext context) =>
      Theme.of(context).colorScheme.error;

  static Color errorContainer(BuildContext context) =>
      Theme.of(context).colorScheme.errorContainer;
}
