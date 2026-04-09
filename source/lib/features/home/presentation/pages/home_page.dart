import 'package:flutter/material.dart';
import 'package:so_thu_chi/l10n/app_localizations.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('page_home'),
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.navHome)),
      body: const SizedBox.shrink(),
    );
  }
}
