import 'package:flutter/material.dart';

class ThemeProvider {
  // Updated background gradient for the login screen
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFFDF6), // #FFFDF6
      Color(0xFFFAF6E9), // #FAF6E9
    ],
  );

  // Card style for the login form
  static BoxDecoration cardDecoration(BuildContext context) => BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      );

  // Main logo asset
  static const String mainLogo = 'assets/logos/main_logo.png';
  // Google logo asset
  static const String googleLogo = 'assets/logos/google_logo.png';

  // Button color
  static const Color primaryButton = Color(0xFFA0C878); // #A0C878
  static const Color googleButtonBorder = Color(0xFFDDEB9D); // #DDEB9D
  static const Color signUpGreen = Color(0xFFA0C878); // #A0C878
  static const Color forgotPassword = Color(0xFFA0C878); // #DDEB9D
}
