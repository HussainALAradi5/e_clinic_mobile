import 'package:flutter/material.dart';

import '../../motion/motion.dart';
import '../../motion/tap_scale.dart';
import '../../theme/status_colors.dart';

/// One choice of a filter track: lifts into a raised pill when selected. A [tone] adds its badge-colour dot.
class FilterPill extends StatelessWidget {
  const FilterPill({super.key, required this.label, required this.selected, required this.onSelected, this.tone});

  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final StatusTone? tone;

  static const double _height = 34;
  static const double _dot = 8;
  static const double _shadowAlpha = 0.16;
  static const double _shadowBlur = 6;
  static const double _shadowOffset = 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tone = this.tone;
    return Semantics(
      button: true,
      selected: selected,
      child: TapScale(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onSelected,
          child: AnimatedContainer(
            duration: Motion.of(context, Motion.base),
            curve: Motion.ease,
            height: _height,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: selected ? scheme.surfaceContainerLowest : Colors.transparent,
              borderRadius: BorderRadius.circular(_height),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: scheme.shadow.withValues(alpha: _shadowAlpha),
                        blurRadius: _shadowBlur,
                        offset: const Offset(0, _shadowOffset),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (tone != null) ...[
                  Container(
                    width: _dot,
                    height: _dot,
                    decoration: BoxDecoration(
                      color: StatusColors.of(tone, theme.brightness).foreground,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: selected ? scheme.onSurface : scheme.onSurfaceVariant,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
