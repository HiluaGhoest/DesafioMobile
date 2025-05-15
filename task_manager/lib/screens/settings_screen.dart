import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/util/language_provider.dart';
import 'package:task_manager/util/theme_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    
    // We'll use AppLocalizations after it's generated
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.settings ?? 'Settings'),
        backgroundColor: ThemeProvider.primaryButton,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Language selection section
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations?.language ?? 'Language',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // English option
                  _buildLanguageOption(
                    context: context,
                    languageCode: 'en',
                    languageName: localizations?.english ?? 'English',
                    isSelected: languageProvider.locale.languageCode == 'en',
                    onTap: () => _changeLanguage(context, const Locale('en')),
                  ),
                  const Divider(),
                  // Portuguese option
                  _buildLanguageOption(
                    context: context,
                    languageCode: 'pt',
                    languageName: localizations?.portuguese ?? 'Português',
                    isSelected: languageProvider.locale.languageCode == 'pt',
                    onTap: () => _changeLanguage(context, const Locale('pt')),
                  ),
                  const Divider(),
                  // Spanish option
                  _buildLanguageOption(
                    context: context,
                    languageCode: 'es',
                    languageName: localizations?.spanish ?? 'Español',
                    isSelected: languageProvider.locale.languageCode == 'es',
                    onTap: () => _changeLanguage(context, const Locale('es')),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required String languageCode,
    required String languageName,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            // Language flag or icon could be added here
            Text(
              languageName,
              style: const TextStyle(fontSize: 16),
            ),
            const Spacer(),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: ThemeProvider.primaryButton,
              ),
          ],
        ),
      ),
    );
  }

  void _changeLanguage(BuildContext context, Locale newLocale) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    languageProvider.setLocale(newLocale);
  }
}
