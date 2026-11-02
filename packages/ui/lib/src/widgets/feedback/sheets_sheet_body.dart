part of 'sheets.dart';

class _SheetBody extends StatelessWidget {
  const _SheetBody({required this.config, required this.onConfirm, this.child});

  final ConfirmConfig config;
  final VoidCallback? onConfirm;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 0, 24, 16 + MediaQuery.viewInsetsOf(context).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(config.title, style: theme.textTheme.titleLarge),
            if (config.message != null) ...[
              const SizedBox(height: 8),
              Text(config.message!, style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
            ],
            if (child != null) ...[const SizedBox(height: 20), child!],
            const SizedBox(height: 24),
            FilledButton(
              style: config.danger
                  ? FilledButton.styleFrom(backgroundColor: scheme.error, foregroundColor: scheme.onError)
                  : null,
              onPressed: onConfirm,
              child: Text(config.confirmLabel),
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(config.cancelLabel)),
          ],
        ),
      ),
    );
  }
}
