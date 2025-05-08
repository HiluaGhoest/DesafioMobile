// lib/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Prevent direct instantiation
  AppColors._();

  static Color primary(BuildContext context) =>
      Theme.of(context).colorScheme.primary;

  static Color secondary(BuildContext context) =>
      Theme.of(context).colorScheme.secondary;

  static Color accent(BuildContext context) =>
      Theme.of(context).colorScheme.tertiary;

  static Color background(BuildContext context) =>
      Theme.of(context).colorScheme.background;

  static Color surface(BuildContext context) =>
      Theme.of(context).colorScheme.surface;

  static Color error(BuildContext context) =>
      Theme.of(context).colorScheme.error;

  static Color success(BuildContext context) =>
      Theme.of(context).colorScheme.secondaryContainer;

  static Color warning(BuildContext context) =>
      Theme.of(context).colorScheme.tertiaryContainer;

  static Color textPrimary(BuildContext context) =>
      Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

  static Color textSecondary(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;
}
