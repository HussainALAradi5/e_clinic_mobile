import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The kinds of visit the desk can book, as coloured chips with the clinic's labels.
class VisitKindChips extends ConsumerWidget {
  const VisitKindChips({super.key, required this.selected, required this.onSelected});

  /// Treatment sessions are booked from the treatment plan on the website.
  static const _types = [
    AppointmentType.consultation,
    AppointmentType.followUp,
    AppointmentType.procedure,
    AppointmentType.emergency,
    AppointmentType.teleconsultation,
  ];

  final AppointmentType selected;
  final ValueChanged<AppointmentType> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(enumCatalogProvider).value ?? EnumCatalog.empty;
    return ChipBar<AppointmentType>(
      options: [for (final t in _types) (value: t, label: catalog.label('AppointmentType', t), count: null)],
      selected: selected,
      tone: (t) => StatusColors.tone('AppointmentType', wireValue(t)),
      onSelected: onSelected,
    );
  }
}
