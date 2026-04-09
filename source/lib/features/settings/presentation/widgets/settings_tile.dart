import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: ListTile(
        minTileHeight: 56,
        leading: Icon(icon),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(route),
      ),
    );
  }
}
