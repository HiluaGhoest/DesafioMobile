// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: const Color(0xFF0A73FF),
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF0A73FF),
        secondary: Color(0xFF4FC3F7),
        tertiary: Color(0xFFFFC107),
        background: Color(0xFFF5F5F5),
        surface: Color(0xFFFFFFFF),
        error: Color(0xFFB00020),
        secondaryContainer: Color(0xFF4CAF50), // success
        tertiaryContainer: Color(0xFFFFA000), // warning
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFF212121)),
        bodyMedium: TextStyle(color: Color(0xFF757575)),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: const Color(0xFF0A73FF),
      scaffoldBackgroundColor: const Color(0xFF121212),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF0A73FF),
        secondary: Color(0xFF4FC3F7),
        tertiary: Color(0xFFFFC107),
        background: Color(0xFF121212),
        surface: Color(0xFF1E1E1E),
        error: Color(0xFFCF6679),
        secondaryContainer: Color(0xFF81C784), // success (lighter green)
        tertiaryContainer: Color(0xFFFFB74D), // warning (lighter amber)
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFFE0E0E0)),
        bodyMedium: TextStyle(color: Color(0xFFBDBDBD)),
      ),
    );
  }
}
