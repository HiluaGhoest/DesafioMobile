import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/util/theme_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:task_manager/util/colors/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(
          localizations?.settings ?? 'Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary(context),
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: Provider.of<ThemeProvider>(context).backgroundGradient,
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Theme settings
            _buildSection(
              context,
              title: 'Appearance',
              icon: Icons.palette,
              children: [
                _buildThemeSelector(context),
              ],
            ),
            
            // Notification settings
            _buildSection(
              context,
              title: 'Notifications',
              icon: Icons.notifications,
              children: [
                _buildNotificationSettings(context),
              ],
            ),
            
            // Debug settings section in debug mode
            if (kDebugMode)
              _buildSection(
                context,
                title: 'Debug Settings',
                icon: Icons.bug_report,
                children: [
                  _buildDebugSettings(context),
                ],
              ),
            
            // About section
            _buildSection(
              context,
              title: 'About',
              icon: Icons.info,
              children: [
                _buildAboutSection(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary(context).withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: AppColors.primary(context),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Column(
      children: [
        ListTile(
          title: const Text('Dark Mode'),
          trailing: Switch(
            value: themeProvider.isDarkMode,
            onChanged: (value) => themeProvider.toggleTheme(),
            activeColor: AppColors.primary(context),
          ),
        ),
        ListTile(
          title: const Text('Color Theme'),
          subtitle: Text(
            themeProvider.currentTheme.toString().split('.').last,
            style: TextStyle(
              color: AppColors.textSecondary(context),
            ),
          ),
          trailing: Icon(
            Icons.color_lens,
            color: AppColors.primary(context),
          ),
          onTap: () => themeProvider.toggleColor(),
        ),
      ],
    );
  }

  Widget _buildNotificationSettings(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: const Text('Task Reminders'),
          trailing: Switch(
            value: true, // Replace with actual value from settings
            onChanged: (value) {
              // Implement notification toggle
            },
            activeColor: AppColors.primary(context),
          ),
        ),
        ListTile(
          title: const Text('Activity Reminders'),
          trailing: Switch(
            value: true, // Replace with actual value from settings
            onChanged: (value) {
              // Implement notification toggle
            },
            activeColor: AppColors.primary(context),
          ),
        ),
        ListTile(
          title: const Text('Reminder Time'),
          subtitle: Text(
            '15 minutes before',
            style: TextStyle(
              color: AppColors.textSecondary(context),
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: AppColors.textSecondary(context),
          ),
          onTap: () {
            // Show reminder time picker
          },
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: const Text('Version'),
          subtitle: Text(
            '1.0.0',
            style: TextStyle(
              color: AppColors.textSecondary(context),
            ),
          ),
        ),
        ListTile(
          title: const Text('Terms of Service'),
          trailing: Icon(
            Icons.chevron_right,
            color: AppColors.textSecondary(context),
          ),
          onTap: () {
            // Navigate to terms of service
          },
        ),
        ListTile(
          title: const Text('Privacy Policy'),
          trailing: Icon(
            Icons.chevron_right,
            color: AppColors.textSecondary(context),
          ),
          onTap: () {
            // Navigate to privacy policy
          },
        ),
        ListTile(
          title: Text(
            'Feedback',
            style: TextStyle(
              color: AppColors.primary(context),
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: AppColors.textSecondary(context),
          ),
          onTap: () {
            // Show feedback dialog
          },
        ),
      ],
    );
  }

  Widget _buildDebugSettings(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final prefs = snapshot.data!;
        final useSimulatedData = prefs.getBool('useSimulatedData') ?? false;

        return Column(
          children: [
            ListTile(
              title: const Text('Use Simulated Data'),
              subtitle: const Text('Toggle between real and simulated data'),
              trailing: Switch(
                value: useSimulatedData,
                onChanged: (value) async {
                  await prefs.setBool('useSimulatedData', value);
                  // Force rebuild
                  (context as Element).markNeedsBuild();
                },
                activeColor: AppColors.primary(context),
              ),
            ),
          ],
        );
      },
    );
  }
}
