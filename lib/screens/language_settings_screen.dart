import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('settings.language.title'.tr()),
        elevation: 0,
      ),
      body: ListView(
        children: [
          _buildLanguageTile(
            context,
            language: 'Français',
            locale: const Locale('fr'),
            flag: '🇫🇷',
          ),
          const Divider(height: 1),
          _buildLanguageTile(
            context,
            language: 'English',
            locale: const Locale('en'),
            flag: '🇬🇧',
          ),
          const Divider(height: 1),
          _buildLanguageTile(
            context,
            language: 'Español',
            locale: const Locale('es'),
            flag: '🇪🇸',
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageTile(
    BuildContext context, {
    required String language,
    required Locale locale,
    required String flag,
  }) {
    final isSelected = context.locale == locale;

    return ListTile(
      leading: Text(
        flag,
        style: const TextStyle(fontSize: 32),
      ),
      title: Text(
        language,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: Theme.of(context).primaryColor,
            )
          : null,
      onTap: () async {
        await context.setLocale(locale);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('settings.language.changed'.tr()),
              duration: const Duration(seconds: 2),
            ),
          );
          // Retour à l'écran précédent
          Navigator.pop(context);
        }
      },
    );
  }
}
