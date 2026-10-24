import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A 6-digit code (two-factor, emailed reset code); calls [onCompleted] as soon as it is complete.
class CodeField extends StatelessWidget {
  const CodeField({super.key, required this.controller, this.onCompleted, this.label = '6-digit code'});

  final TextEditingController controller;
  final ValueChanged<String>? onCompleted;
  final String label;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    autofocus: true,
    keyboardType: TextInputType.number,
    textAlign: TextAlign.center,
    autofillHints: const [AutofillHints.oneTimeCode],
    inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
    style: Theme.of(context).textTheme.headlineSmall?.copyWith(letterSpacing: 12, fontWeight: FontWeight.w600),
    decoration: InputDecoration(labelText: label, counterText: ''),
    onChanged: (value) {
      if (value.length == 6) onCompleted?.call(value);
    },
  );
}
