import 'package:flutter/material.dart';

import '../../../constants/common/common_text.dart';
import '../../../constants/staff/scan_text.dart';

/// For a code that will not scan (damaged label, emulator without a camera): the text printed under it.
class TypeCodeDialog extends StatefulWidget {
  const TypeCodeDialog({super.key, this.label = ScanText.code, this.hint = 'appointment:APT-…'});

  final String label;
  final String hint;

  @override
  State<TypeCodeDialog> createState() => _TypeCodeDialogState();
}

class _TypeCodeDialogState extends State<TypeCodeDialog> {
  final _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text(ScanText.typeCode),
    content: TextField(
      controller: _code,
      autofocus: true,
      autocorrect: false,
      decoration: InputDecoration(labelText: widget.label, hintText: widget.hint),
      onSubmitted: (value) => Navigator.of(context).pop(value),
    ),
    actions: [
      TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text(CommonText.cancel)),
      FilledButton(onPressed: () => Navigator.of(context).pop(_code.text), child: const Text(ScanText.lookUp)),
    ],
  );
}
