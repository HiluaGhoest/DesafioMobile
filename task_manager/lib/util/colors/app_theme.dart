import 'package:flutter/material.dart';

enum ThemeVariant {
  lightGreen,
  lightBlue,
  darkGreen,
  darkBlue,
}

class AppTheme {
  AppTheme._(); // Private constructor to prevent instantiation
  
  static final _greenPrimary = const Color(0xFF4CAF50);
  static final _bluePrimary = const Color(0xFF0A73FF);
  
  // Cache for theme instances and color schemes
  static final Map<ThemeVariant, ThemeData> _themeCache = {};
  static final Map<ThemeVariant, ColorScheme> _colorSchemeCache = {};
  
  static final _lightTextTheme = const TextTheme(
    bodyLarge: TextStyle(color: Color(0xFF212121)),
    bodyMedium: TextStyle(color: Color(0xFF757575)),
  );
  
  static final _darkTextTheme = const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white70),
  );

  static ThemeData getTheme(ThemeVariant variant) {
    return _themeCache[variant] ??= _createTheme(variant);
  }

  static ThemeData _createTheme(ThemeVariant variant) {
    final primaryColor = variant == ThemeVariant.lightGreen || variant == ThemeVariant.darkGreen 
        ? _greenPrimary 
        : _bluePrimary;
        
    final isDark = variant == ThemeVariant.darkBlue || variant == ThemeVariant.darkGreen;
    
    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
      colorScheme: _getColorScheme(variant, primaryColor, isDark),
      textTheme: _getTextTheme(isDark),
      // Disable animations and transitions
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      visualDensity: VisualDensity.standard,
      splashFactory: NoSplash.splashFactory,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  static ColorScheme _getColorScheme(ThemeVariant variant, Color primaryColor, bool isDark) {
    return _colorSchemeCache[variant] ??= (isDark ? ColorScheme.dark : ColorScheme.light)(
      primary: primaryColor,
      secondary: primaryColor.withOpacity(0.8),
      tertiary: const Color(0xFFFFC107),
      surface: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF),
      error: isDark ? const Color(0xFFCF6679) : const Color(0xFFB00020),
      secondaryContainer: isDark ? const Color(0xFF81C784) : const Color(0xFF4CAF50),
      tertiaryContainer: isDark ? const Color(0xFFFFB74D) : const Color(0xFFFFA000),
    );
  }

  static TextTheme _getTextTheme(bool isDark) {
    return isDark ? _darkTextTheme : _lightTextTheme;
  }
}
