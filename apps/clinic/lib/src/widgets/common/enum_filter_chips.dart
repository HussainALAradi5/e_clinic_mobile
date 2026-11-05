import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/common/common_text.dart';

/// All plus each of [values] of an enum, each chip in the colour its badge wears (labels from the clinic's
/// catalog). `null` is All. Used for visit timing, payment state, paid by and result kind.
class EnumFilterChips<T extends Enum> extends ConsumerWidget {
  const EnumFilterChips({
    super.key,
    required this.enumName,
    required this.values,
    required this.selected,
    required this.onSelected,
  });

  final String enumName;
  final List<T> values;
  final T? selected;
  final ValueChanged<T?> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(enumCatalogProvider).value ?? EnumCatalog.empty;
    return ChipBar<T?>(
      options: [
        (value: null, label: CommonText.all, count: null),
        for (final v in values) (value: v, label: catalog.label(enumName, v), count: null),
      ],
      selected: selected,
      tone: (v) => v == null ? null : StatusColors.tone(enumName, wireValue(v)),
      onSelected: onSelected,
    );
  }
}
