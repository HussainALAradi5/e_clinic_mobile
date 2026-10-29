import 'package:flutter/material.dart';

/// What a confirmation asks; `danger` paints the confirm button in the error colour.
class ConfirmConfig {
  const ConfirmConfig({
    required this.title,
    this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Not now',
    this.danger = false,
  });

  final String title;
  final String? message;
  final String confirmLabel;
  final String cancelLabel;
  final bool danger;
}

/// Bottom-sheet confirmation; true only when the user confirmed.
Future<bool> showConfirmSheet(BuildContext context, ConfirmConfig config) async =>
    await showModalBottomSheet<bool>(
      context: context,
      builder: (context) => _SheetBody(config: config, onConfirm: () => Navigator.of(context).pop(true)),
    ) ??
    false;

/// Bottom-sheet confirmation that needs a reason (cancel, reject); null when dismissed.
Future<String?> showReasonSheet(BuildContext context, ConfirmConfig config, {String label = 'Reason'}) =>
    showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _ReasonSheet(config: config, label: label),
    );

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

class _ReasonSheet extends StatefulWidget {
  const _ReasonSheet({required this.config, required this.label});

  final ConfirmConfig config;
  final String label;

  @override
  State<_ReasonSheet> createState() => _ReasonSheetState();
}

class _ReasonSheetState extends State<_ReasonSheet> {
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: _reason,
    builder: (context, value, _) => _SheetBody(
      config: widget.config,
      onConfirm: value.text.trim().isEmpty ? null : () => Navigator.of(context).pop(value.text.trim()),
      child: TextField(
        controller: _reason,
        autofocus: true,
        maxLength: 500,
        minLines: 2,
        maxLines: 4,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(labelText: widget.label),
      ),
    ),
  );
}
