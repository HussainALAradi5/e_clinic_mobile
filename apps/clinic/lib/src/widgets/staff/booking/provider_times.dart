import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/common/common_text.dart';
import '../../../controllers/staff/calendar_providers.dart';

/// The chosen provider's days and free times on the chosen day.
class ProviderTimes extends ConsumerWidget {
  const ProviderTimes({
    super.key,
    required this.slotKey,
    required this.days,
    required this.selected,
    required this.onDay,
    required this.onPick,
  });

  final StaffSlotKey slotKey;
  final List<String> days;
  final Slot? selected;
  final ValueChanged<String> onDay;
  final ValueChanged<Slot> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(CommonText.day),
        DayStrip(days: days, selected: slotKey.date, onSelected: onDay),
        const SectionHeader(CommonText.time),
        SlotPicker(
          slots: ref.watch(staffSlotsProvider(slotKey)),
          selected: selected,
          onPick: onPick,
          onRetry: () => ref.invalidate(staffSlotsProvider(slotKey)),
        ),
      ],
    );
  }
}
