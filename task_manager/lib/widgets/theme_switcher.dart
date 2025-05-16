import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/util/theme_provider.dart';
import 'package:task_manager/util/colors/app_theme.dart';
import 'package:task_manager/util/colors/app_colors.dart';

class ThemeSwitcher extends StatelessWidget {
  const ThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return PopupMenuButton<ThemeVariant>(
          icon: Icon(
            Icons.palette,
            color: AppColors.surface(context),
          ),
          onSelected: themeProvider.setTheme,
          itemBuilder: (_) => _buildMenuItems(context, themeProvider.currentTheme),
        );
      },
    );
  }

  static final _menuItems = <ThemeVariant, Widget>{};

  List<PopupMenuEntry<ThemeVariant>> _buildMenuItems(BuildContext context, ThemeVariant currentTheme) {
    return [
      _buildMenuItem(context, ThemeVariant.lightBlue, 'Light Blue', Icons.light_mode, currentTheme),
      _buildMenuItem(context, ThemeVariant.lightGreen, 'Light Green', Icons.light_mode, currentTheme),
      _buildMenuItem(context, ThemeVariant.darkBlue, 'Dark Blue', Icons.dark_mode, currentTheme),
      _buildMenuItem(context, ThemeVariant.darkGreen, 'Dark Green', Icons.dark_mode, currentTheme),
    ];
  }

  PopupMenuItem<ThemeVariant> _buildMenuItem(
    BuildContext context,
    ThemeVariant variant,
    String title,
    IconData icon,
    ThemeVariant currentTheme,
  ) {
    // Return cached menu item if it exists and theme hasn't changed
    final cacheKey = variant;
    if (_menuItems.containsKey(cacheKey) && currentTheme != variant) {
      return PopupMenuItem(
        value: variant,
        child: _menuItems[cacheKey]!,
      );
    }

    final item = ListTile(
      leading: Icon(
        icon,
        color: AppTheme.getTheme(variant).primaryColor,
      ),
      title: Text(title),
      trailing: currentTheme == variant
          ? Icon(Icons.check, color: AppColors.primary(context))
          : null,
    );

    // Cache the item if it's not the current theme
    if (currentTheme != variant) {
      _menuItems[cacheKey] = item;
    }

    return PopupMenuItem(
      value: variant,
      child: item,
    );
  }
}