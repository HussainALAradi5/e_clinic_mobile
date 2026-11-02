import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../controllers/portal/booking_providers.dart';

/// Times a patient can still book online with the chosen doctor and day.
class SlotChoices extends ConsumerWidget {
  const SlotChoices({super.key, required this.slotKey, required this.selected, required this.onPick});

  final SlotKey slotKey;
  final Slot? selected;
  final ValueChanged<Slot> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) => SlotPicker(
    slots: ref.watch(slotsProvider(slotKey)),
    selected: selected,
    onPick: onPick,
    onRetry: () => ref.invalidate(slotsProvider(slotKey)),
  );
}
