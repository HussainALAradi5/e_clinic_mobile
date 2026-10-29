import 'package:e_clinic_core/core.dart';
import 'package:flutter/material.dart';

/// One selectable day (weekday, day, month); read out as the full date.
class DayChip extends StatelessWidget {
  const DayChip({super.key, required this.date, required this.selected, required this.onTap});

  final String date;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final parts = ClinicClock.parts(date);
    final foreground = selected ? scheme.onPrimary : scheme.onSurface;
    return Semantics(
      selected: selected,
      button: true,
      label: ClinicClock.day(date),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: selected ? scheme.primary : scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? scheme.primary : scheme.outlineVariant),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: SizedBox(
              width: 60,
              child: ExcludeSemantics(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(parts.weekday, style: theme.textTheme.labelSmall?.copyWith(color: foreground)),
                    Text(
                      '${parts.day}',
                      style: theme.textTheme.titleLarge?.copyWith(color: foreground, fontWeight: FontWeight.w700),
                    ),
                    Text(parts.month, style: theme.textTheme.labelSmall?.copyWith(color: foreground)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
