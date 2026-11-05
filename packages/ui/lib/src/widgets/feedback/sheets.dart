import 'package:flutter/material.dart';

import '../../constants/ui_text.dart';

part 'sheets_reason_sheet.dart';
part 'sheets_reason_sheet_state.dart';
part 'sheets_sheet_body.dart';

/// What a confirmation asks; `danger` paints the confirm button in the error colour.
class ConfirmConfig {
  const ConfirmConfig({
    required this.title,
    this.message,
    this.confirmLabel = UiText.confirm,
    this.cancelLabel = UiText.notNow,
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
Future<String?> showReasonSheet(BuildContext context, ConfirmConfig config, {String label = UiText.reason}) =>
    showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _ReasonSheet(config: config, label: label),
    );
