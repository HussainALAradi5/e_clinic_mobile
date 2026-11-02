import 'package:flutter/material.dart';

class ScanResultTitle extends StatelessWidget {
  const ScanResultTitle({super.key, required this.title, required this.code});

  final String title;
  final String code;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
      child: Row(
        children: [
          Icon(Icons.qr_code_2_rounded, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: theme.textTheme.titleLarge)),
          Text(code, style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
