import 'package:e_clinic_core/core.dart';
import 'package:flutter/material.dart';

/// `SUN / 25 / OCT` block at the start of a visit or booking.
class DateBlock extends StatelessWidget {
  const DateBlock({super.key, required this.date, this.highlighted = false});

  /// ISO date (`YYYY-MM-DD`).
  final String date;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final parts = ClinicClock.parts(date);
    final foreground = highlighted ? scheme.onPrimaryContainer : scheme.onSurfaceVariant;
    return Container(
      width: 58,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: highlighted ? scheme.primaryContainer : scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(parts.weekday, style: theme.textTheme.labelSmall?.copyWith(color: foreground)),
          Text(
            '${parts.day}',
            style: theme.textTheme.titleLarge?.copyWith(color: foreground, fontWeight: FontWeight.w700, height: 1.1),
          ),
          Text(parts.month, style: theme.textTheme.labelSmall?.copyWith(color: foreground)),
        ],
      ),
    );
  }
}

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

/// A row of [DayChip]s that scrolls sideways (booking a day, a therapist's week).
class DayStrip extends StatelessWidget {
  const DayStrip({super.key, required this.days, required this.selected, required this.onSelected});

  final List<String> days;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 84,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: days.length,
      separatorBuilder: (_, _) => const SizedBox(width: 8),
      itemBuilder: (_, i) => DayChip(date: days[i], selected: days[i] == selected, onTap: () => onSelected(days[i])),
    ),
  );
}
