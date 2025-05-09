import 'package:flutter/material.dart';

/// A utility class that provides standardized theme elements throughout the app.
/// 
/// This class contains constants and methods for UI elements like gradients,
/// decorations, and common asset paths.
class ThemeProvider {  /// Background gradient for the login and authentication screens.
  /// 
  /// A subtle cream-to-off-white gradient that creates a warm, inviting atmosphere
  /// for user onboarding flows.
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFFDF6), // #FFFDF6
      Color(0xFFFAF6E9), // #FAF6E9
    ],
  );

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
  static const Color primaryButton = Color(0xFFA0C878); // #A0C878
  
  /// Border color for Google sign-in button
  static const Color googleButtonBorder = Color(0xFFDDEB9D); // #DDEB9D
  
  /// Green color used for sign-up related UI elements
  static const Color signUpGreen = Color(0xFFA0C878); // #A0C878
  
  /// Color used for forgot password links and related elements
  static const Color forgotPassword = Color(0xFFA0C878); // #DDEB9D
  
  /// Primary red color for destructive actions or errors
  static const Color red = Color(0xFFEA4C2D); // #EA4C2D
  
  /// Lighter red color for less critical warnings or secondary error states
  static const Color lightRed = Color(0xFFFF8B8B); // #FFE6E6
}
