import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../feedback/error_state.dart';

/// Free times of a day as chips (patient and staff booking).
class SlotPicker extends StatelessWidget {
  const SlotPicker({super.key, required this.slots, required this.selected, required this.onPick, this.onRetry});

  final AsyncValue<List<Slot>> slots;
  final Slot? selected;
  final ValueChanged<Slot> onPick;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: slots.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => ErrorState(error: error, onRetry: onRetry),
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
                    label: Text(ClinicClock.wallTime(slot.startTime)),
                    selected: selected?.startTime == slot.startTime,
                    onSelected: (_) => onPick(slot),
                  ),
              ],
            ),
    ),
  );
}
