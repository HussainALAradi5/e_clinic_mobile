import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// All · Coming · Today · Past · Missed, each chip in the colour the visit cards carry. `null` is All.
class VisitTimingFilter extends ConsumerWidget {
  const VisitTimingFilter({super.key, required this.selected, required this.onSelected});

  final VisitTiming? selected;
  final ValueChanged<VisitTiming?> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(enumCatalogProvider).value ?? EnumCatalog.empty;
    return ChipBar<VisitTiming?>(
      options: [
        (value: null, label: 'All', count: null),
        for (final t in VisitTiming.filters) (value: t, label: catalog.label('VisitTiming', t), count: null),
      ],
      selected: selected,
      tone: (t) => t == null ? null : StatusColors.tone('VisitTiming', wireValue(t)),
      onSelected: onSelected,
    );
  }
}
