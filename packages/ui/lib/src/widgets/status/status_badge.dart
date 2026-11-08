import 'package:flutter/material.dart';

import '../../theme/status_colors.dart';

/// A coloured pill with a dot and written label; long labels wrap inside it.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, required this.tone});

  final String label;
  final StatusTone tone;

  static const double _dot = 6;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = StatusColors.of(tone, theme.brightness);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(999),
        border: colors.border == null ? null : Border.all(color: colors.border!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: _dot,
            height: _dot,
            decoration: BoxDecoration(color: colors.foreground, shape: BoxShape.circle),
          ),
          const SizedBox(width: _dot),
          Flexible(
            child: Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(color: colors.foreground, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
