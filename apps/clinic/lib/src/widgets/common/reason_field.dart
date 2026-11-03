import 'package:flutter/material.dart';

/// An optional free-text reason (up to [maxLength] characters), padded to the screen edges.
class ReasonField extends StatelessWidget {
  const ReasonField({
    super.key,
    required this.controller,
    this.hint,
    this.minLines = 1,
    this.maxLines = 3,
    this.maxLength = 500,
  });

  final TextEditingController controller;
  final String? hint;
  final int minLines;
  final int maxLines;
  final int maxLength;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: controller,
        maxLength: maxLength,
        minLines: minLines,
        maxLines: maxLines,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(hintText: hint),
      ),
    );
  }
}
