import 'package:flutter/material.dart';

class TicketPill extends StatelessWidget {
  const TicketPill({super.key, required this.text, required this.color, required this.textColor});

  final String text;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(999)),
    child: Text(
      text,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(color: textColor, fontWeight: FontWeight.w600),
    ),
  );
}
