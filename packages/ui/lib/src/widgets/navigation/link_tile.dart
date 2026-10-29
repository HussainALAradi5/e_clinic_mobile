import 'package:flutter/material.dart';

/// A row that leads to another page, inside a card of links.
class LinkTile extends StatelessWidget {
  const LinkTile({super.key, required this.icon, required this.label, required this.onTap, this.subtitle});

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    shape: const RoundedRectangleBorder(),
    leading: Icon(icon),
    title: Text(label),
    subtitle: subtitle == null ? null : Text(subtitle!),
    trailing: const Icon(Icons.chevron_right_rounded),
    onTap: onTap,
  );
}
