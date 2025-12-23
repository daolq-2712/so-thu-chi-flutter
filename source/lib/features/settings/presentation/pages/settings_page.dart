import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('page_settings'),
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.navSettings)),
      body: const SizedBox.shrink(),
    );
  }
}
