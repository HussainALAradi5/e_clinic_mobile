part of 'new_ticket_screen.dart';

/// One choice out of an enum's [values], as chips coloured like the badges and labelled by the clinic.
class _ToneChoices extends ConsumerWidget {
  const _ToneChoices({required this.enumName, required this.values, required this.selected, required this.onSelected});

  final String enumName;
  final List<String> values;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(enumCatalogProvider).value ?? EnumCatalog.empty;
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        for (final v in values)
          ToneChip(
            label: catalog.label(enumName, v),
            selected: v == selected,
            onSelected: () => onSelected(v),
            tone: StatusColors.tone(enumName, v, order: catalog.values(enumName)),
          ),
      ],
    );
  }
}
