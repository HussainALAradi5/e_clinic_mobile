import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/booking_providers.dart';

class SlotChoices extends ConsumerWidget {
  const SlotChoices({super.key, required this.slotKey, required this.selected, required this.onPick});

  final SlotKey slotKey;
  final Slot? selected;
  final ValueChanged<Slot> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slots = ref.watch(slotsProvider(slotKey));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: slots.when(
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => ErrorState(error: error, onRetry: () => ref.invalidate(slotsProvider(slotKey))),
        data: (list) => list.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'No free times this day — try another day.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              )
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final slot in list)
                    ChoiceChip(
                      label: Text(slot.startTime),
                      selected: selected?.startTime == slot.startTime,
                      onSelected: (_) => onPick(slot),
                    ),
                ],
              ),
      ),
    );
  }
}
