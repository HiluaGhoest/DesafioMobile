import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager/util/colors/app_colors.dart';
import 'package:task_manager/util/colors/app_theme.dart';

/// A utility class that provides standardized theme elements throughout the app.
/// 
/// This class contains constants and methods for UI elements like gradients,
/// decorations, and common asset paths.
class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'selected_theme';
  final SharedPreferences _prefs;
  
  // Cache for background gradients and themes
  final Map<ThemeVariant, LinearGradient> _gradientCache = {};
  ThemeData? _cachedTheme;
  ThemeVariant _currentTheme = ThemeVariant.lightBlue;
  
  ThemeProvider(this._prefs) {
    _loadSavedTheme();
    _cacheGradients();
  }

  void _loadSavedTheme() {
    final savedTheme = _prefs.getString(_themeKey);
    if (savedTheme != null) {
      _currentTheme = ThemeVariant.values.firstWhere(
        (e) => e.toString() == savedTheme,
        orElse: () => ThemeVariant.lightBlue,
      );
      _cachedTheme = AppTheme.getTheme(_currentTheme);
    }
  }
  
  ThemeVariant get currentTheme => _currentTheme;
  ThemeData get theme => _cachedTheme ?? AppTheme.getTheme(_currentTheme);
  bool get isDarkMode => _currentTheme == ThemeVariant.darkBlue || 
                        _currentTheme == ThemeVariant.darkGreen;

  Future<void> setTheme(ThemeVariant variant) async {
    if (_currentTheme != variant) {
      _currentTheme = variant;
      _cachedTheme = AppTheme.getTheme(variant);
      await _prefs.setString(_themeKey, variant.toString());
      notifyListeners();
    }
  }

  void toggleTheme() {
    final newTheme = switch (_currentTheme) {
      ThemeVariant.lightBlue => ThemeVariant.darkBlue,
      ThemeVariant.lightGreen => ThemeVariant.darkGreen,
      ThemeVariant.darkBlue => ThemeVariant.lightBlue,
      ThemeVariant.darkGreen => ThemeVariant.lightGreen,
    };
    setTheme(newTheme);
  }

  void toggleColor() {
    final newTheme = switch (_currentTheme) {
      ThemeVariant.lightBlue => ThemeVariant.lightGreen,
      ThemeVariant.lightGreen => ThemeVariant.lightBlue,
      ThemeVariant.darkBlue => ThemeVariant.darkGreen,
      ThemeVariant.darkGreen => ThemeVariant.darkBlue,
    };
    setTheme(newTheme);
  }

  void _cacheGradients() {
    const darkGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF000000), Color(0xFF000000)],
    );

    const lightGreenGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFE8F5E9), Color(0xFFF5F5F5)],
    );

    const lightBlueGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFE3F2FD), Color(0xFFF5F5F5)],
    );

    _gradientCache[ThemeVariant.darkBlue] = darkGradient;
    _gradientCache[ThemeVariant.darkGreen] = darkGradient;
    _gradientCache[ThemeVariant.lightGreen] = lightGreenGradient;
    _gradientCache[ThemeVariant.lightBlue] = lightBlueGradient;
  }

  LinearGradient get backgroundGradient => _gradientCache[_currentTheme]!;

  /// Card decoration style used for authentication forms and dialogs.
  /// 
  /// Provides a semi-transparent white background with rounded corners and a subtle shadow
  /// for an elevated appearance that follows material design principles.
  static BoxDecoration cardDecoration(BuildContext context) => BoxDecoration(
        color: Colors.white.withAlpha((0.85 * 255).toInt()),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.08 * 255).toInt()),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      );
  /// Path to the application's main logo image asset.
  /// Used in the login screen, app bar, and other branding locations.
  static const String mainLogo = 'assets/logos/main_logo.png';
  
  /// Path to the Google logo image asset.
  /// Used specifically for Google sign-in buttons.
  static const String googleLogo = 'assets/logos/google_logo.png';

  // Button color  /// Primary button color - green shade used for primary actions
  @deprecated
  static Color primaryButton(BuildContext context) => AppColors.primary(context);
  
  /// Border color for Google sign-in button
  @deprecated
  static Color googleButtonBorder(BuildContext context) => AppColors.surface(context);
  
  /// Green color used for sign-up related UI elements
  @deprecated
  static Color signUpGreen(BuildContext context) => AppColors.success(context);
  
  /// Color used for forgot password links and related elements
  @deprecated
  static Color forgotPassword(BuildContext context) => AppColors.primary(context);
  
  /// Primary red color for destructive actions or errors
  @deprecated
  static Color red(BuildContext context) => AppColors.error(context);
  
  /// Lighter red color for less critical warnings or secondary error states
  @deprecated
  static Color lightRed(BuildContext context) => AppColors.error(context).withOpacity(0.3);
}
