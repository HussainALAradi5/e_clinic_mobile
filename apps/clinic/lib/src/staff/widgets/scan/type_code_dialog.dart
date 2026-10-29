import 'package:flutter/material.dart';

/// For a code that will not scan (damaged label, emulator without a camera): the text printed under it.
class TypeCodeDialog extends StatefulWidget {
  const TypeCodeDialog({super.key});

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
    title: const Text('Type the code'),
    content: TextField(
      controller: _code,
      autofocus: true,
      autocorrect: false,
      decoration: const InputDecoration(labelText: 'Code', hintText: 'appointment:APT-…'),
      onSubmitted: (value) => Navigator.of(context).pop(value),
    ),
    actions: [
      TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
      FilledButton(onPressed: () => Navigator.of(context).pop(_code.text), child: const Text('Look up')),
    ],
  );
}
