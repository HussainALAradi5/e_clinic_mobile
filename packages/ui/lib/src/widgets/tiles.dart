import 'package:e_clinic_core/core.dart';
import 'package:flutter/material.dart';

/// Top of a home screen: today's date and a greeting by the time of day, with optional actions (messages bell).
class GreetingHeader extends StatelessWidget {
  const GreetingHeader({super.key, required this.firstName, this.trailing});

  final String firstName;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hour = ClinicClock.now().hour;
    final greeting = hour < 12 ? 'Good morning' : (hour < 18 ? 'Good afternoon' : 'Good evening');
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 8, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ClinicClock.day(ClinicClock.today()),
                  style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 2),
                Text(firstName.isEmpty ? greeting : '$greeting, $firstName', style: theme.textTheme.headlineSmall),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Avatar with initials, name and up to two lines under it (account and profile pages).
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.name, this.lines = const []});

  final String name;

  /// Shown muted under the name; empty lines are left out.
  final List<String?> lines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: scheme.primaryContainer,
          foregroundColor: scheme.onPrimaryContainer,
          child: Text(initials(name), style: theme.textTheme.titleLarge),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: theme.textTheme.titleLarge),
              for (final line in lines)
                if (line != null && line.isNotEmpty)
                  Text(line, style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
            ],
          ),
        ),
      ],
    );
  }
}

/// A row that leads to another page, inside a card of links.
class LinkTile extends StatelessWidget {
  const LinkTile({super.key, required this.icon, required this.label, required this.onTap, this.subtitle});

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    shape: const RoundedRectangleBorder(),
    leading: Icon(icon),
    title: Text(label),
    subtitle: subtitle == null ? null : Text(subtitle!),
    trailing: const Icon(Icons.chevron_right_rounded),
    onTap: onTap,
  );
}

/// Links stacked in one card with dividers between them.
class LinkGroup extends StatelessWidget {
  const LinkGroup({super.key, required this.links});

  final List<LinkTile> links;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: Column(
      children: [
        for (var i = 0; i < links.length; i++) ...[if (i > 0) const Divider(height: 1, indent: 56), links[i]],
      ],
    ),
  );
}

/// A short muted line with an icon: hints, "nothing here" notes, what happens next.
class InfoNote extends StatelessWidget {
  const InfoNote({super.key, required this.text, this.icon = Icons.info_outline_rounded});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: muted),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: theme.textTheme.bodyMedium?.copyWith(color: muted)),
          ),
        ],
      ),
    );
  }
}

/// One choice out of a few, as a sideways-scrolling row of chips (stages, tabs of a list); each may carry a count.
class ChipBar<T> extends StatelessWidget {
  const ChipBar({super.key, required this.options, required this.selected, required this.onSelected});

  final List<({T value, String label, int? count})> options;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 40,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: options.length,
      separatorBuilder: (_, _) => const SizedBox(width: 8),
      itemBuilder: (_, i) {
        final option = options[i];
        return ChoiceChip(
          label: Text(option.count == null ? option.label : '${option.label} ${option.count}'),
          selected: option.value == selected,
          onSelected: (_) => onSelected(option.value),
        );
      },
    ),
  );
}
