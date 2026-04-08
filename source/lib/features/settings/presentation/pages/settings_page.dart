import 'package:flutter/material.dart';
import 'package:so_thu_chi/features/settings/presentation/widgets/settings_tile.dart';
import 'package:so_thu_chi/l10n/app_localizations.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      key: const Key('page_settings'),
      appBar: AppBar(title: Text(l10n.navSettings)),
      body: ListView(
        children: [
          SettingsTile(
            key: const Key('tile_language'),
            label: l10n.settingsLanguage,
            icon: Icons.language,
            route: '/settings/language',
          ),
          SettingsTile(
            key: const Key('tile_categories'),
            label: l10n.settingsCategories,
            icon: Icons.category,
            route: '/settings/categories',
          ),
        ],
      ),
    );
  }
}
