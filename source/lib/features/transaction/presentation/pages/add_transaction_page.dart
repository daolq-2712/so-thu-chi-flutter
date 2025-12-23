import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddTransactionPage extends StatelessWidget {
  const AddTransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('page_add_transaction'),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.fabAddTransaction),
      ),
      body: const SizedBox.shrink(),
    );
  }
}
