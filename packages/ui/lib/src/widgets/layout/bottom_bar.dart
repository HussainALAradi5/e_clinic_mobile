import 'package:flutter/material.dart';

/// The bar under a form with its one main button, and an optional line summing up what will happen.
class BottomBar extends StatelessWidget {
  const BottomBar({super.key, required this.child, this.summary});

  final Widget child;
  final String? summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLowest,
          border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (summary != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(summary!, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
              ),
            child,
          ],
        ),
      ),
    );
  }
}
