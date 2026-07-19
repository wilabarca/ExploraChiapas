import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static const _green = Color(0xFF2E7D32);
  static const _greenDark = Color(0xFF4CAF50);

  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: _green,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFDCFCE7),
      onPrimaryContainer: Color(0xFF1B4332),
      secondary: Color(0xFF388E3C),
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFBBF7D0),
      onSecondaryContainer: Color(0xFF14532D),
      surface: Colors.white,
      onSurface: Color(0xFF1B1B1B),
      surfaceContainerLowest: Color(0xFFF8F8F8),
      surfaceContainerLow: Color(0xFFF3F4F6),
      surfaceContainer: Color(0xFFE5E7EB),
      outline: Color(0xFFDDDDDD),
      outlineVariant: Color(0xFFE5E7EB),
      error: Color(0xFFD32F2F),
      onError: Colors.white,
      errorContainer: Color(0xFFFFEBEE),
      onErrorContainer: Color(0xFFB71C1C),
      scrim: Colors.black,
      shadow: Colors.black,
      inverseSurface: Color(0xFF1E1E1E),
      onInverseSurface: Colors.white,
      inversePrimary: _greenDark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFF8F8F8),
      textTheme: GoogleFonts.poppinsTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF1B1B1B),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: const CardTheme(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          side: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: Color(0xFFAAAAAA)),
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFFE5E7EB)),
      iconTheme: const IconThemeData(color: Color(0xFF555555)),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: _green,
        unselectedItemColor: Color(0xFF9CA3AF),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF3F4F6),
        selectedColor: _green,
        labelStyle: const TextStyle(fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _green,
        foregroundColor: Colors.white,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? _green : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? _green.withValues(alpha: 0.5)
              : null,
        ),
      ),
    );
  }

  static ThemeData dark() {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: _greenDark,
      onPrimary: Colors.black,
      primaryContainer: Color(0xFF1B4332),
      onPrimaryContainer: Color(0xFFDCFCE7),
      secondary: Color(0xFF66BB6A),
      onSecondary: Colors.black,
      secondaryContainer: Color(0xFF14532D),
      onSecondaryContainer: Color(0xFFBBF7D0),
      surface: Color(0xFF1E1E1E),
      onSurface: Color(0xFFEEEEEE),
      surfaceContainerLowest: Color(0xFF121212),
      surfaceContainerLow: Color(0xFF1A1A1A),
      surfaceContainer: Color(0xFF252525),
      outline: Color(0xFF3A3A3A),
      outlineVariant: Color(0xFF2C2C2C),
      error: Color(0xFFEF5350),
      onError: Colors.black,
      errorContainer: Color(0xFF4A0000),
      onErrorContainer: Color(0xFFFFCDD2),
      scrim: Colors.black,
      shadow: Colors.black,
      inverseSurface: Colors.white,
      onInverseSurface: Color(0xFF1B1B1B),
      inversePrimary: _green,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFF121212),
      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData(brightness: Brightness.dark).textTheme,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Color(0xFFEEEEEE),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: const CardTheme(
        color: Color(0xFF1E1E1E),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          side: BorderSide(color: Color(0xFF2C2C2C)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF252525),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: Color(0xFF666666)),
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFF2C2C2C)),
      iconTheme: const IconThemeData(color: Color(0xFFAAAAAA)),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E1E1E),
        selectedItemColor: _greenDark,
        unselectedItemColor: Color(0xFF6B7280),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF252525),
        selectedColor: _greenDark,
        labelStyle: const TextStyle(fontSize: 13, color: Color(0xFFEEEEEE)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _greenDark,
        foregroundColor: Colors.black,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? _greenDark : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? _greenDark.withValues(alpha: 0.5)
              : null,
        ),
      ),
    );
  }
}
