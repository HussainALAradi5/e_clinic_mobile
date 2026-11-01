import 'package:e_clinic_core/core.dart';
import 'package:flutter/material.dart';

/// A nationality or country as a pill with its flag: `🇧🇭 Bahraini`.
class FlagBadge extends StatelessWidget {
  const FlagBadge({super.key, required this.countryCode, required this.label});

  final String? countryCode;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final flag = flagEmoji(countryCode);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Text(
        flag.isEmpty ? label : '$flag  $label',
        style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}
