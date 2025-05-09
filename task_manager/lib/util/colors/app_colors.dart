// lib/util/colors/app_colors.dart
import 'package:flutter/material.dart';

/// A utility class that provides standardized color access throughout the app.
/// 
/// This class abstracts Material Design colors from the current theme,
/// ensuring consistent color usage and making theme changes easier to implement.
class AppColors {
  // Prevent direct instantiation
  AppColors._();
  /// Returns the primary color from the current theme.
  /// Used for key components like app bars, buttons, etc.
  static Color primary(BuildContext context) =>
      Theme.of(context).colorScheme.primary;

  /// Returns the secondary color from the current theme.
  /// Used for less prominent components that complement the primary color.
  static Color secondary(BuildContext context) =>
      Theme.of(context).colorScheme.secondary;

  /// Returns the accent/tertiary color from the current theme.
  /// Used for special UI elements that need to stand out.
  static Color accent(BuildContext context) =>
      Theme.of(context).colorScheme.tertiary;  /// Returns the background color from the current theme.
  /// Used for the main background of screens.
  static Color background(BuildContext context) =>
      Theme.of(context).colorScheme.surface;

  /// Returns the surface color from the current theme.
  /// Used for cards, dialogs, and other raised surfaces.
  static Color surface(BuildContext context) =>
      Theme.of(context).colorScheme.surface;

  /// Returns the error color from the current theme.
  /// Used for error states, validation messages, etc.
  static Color error(BuildContext context) =>
      Theme.of(context).colorScheme.error;

  /// Returns a success color from the current theme.
  /// Used for success states and confirmations.
  static Color success(BuildContext context) =>
      Theme.of(context).colorScheme.secondaryContainer;

  /// Returns a warning color from the current theme.
  /// Used for warning states and alerts.
  static Color warning(BuildContext context) =>
      Theme.of(context).colorScheme.tertiaryContainer;
  /// Returns the primary text color from the current theme.
  /// Used for main content text like headings and body text.
  /// Falls back to black if the theme doesn't define a color.
  static Color textPrimary(BuildContext context) =>
      Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

  /// Returns the secondary text color from the current theme.
  /// Used for less important text like captions, hints, etc.
  /// Falls back to grey if the theme doesn't define a color.
  static Color textSecondary(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;
}
