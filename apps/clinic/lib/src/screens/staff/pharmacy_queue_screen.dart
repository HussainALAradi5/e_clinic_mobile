import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/routes/staff_paths.dart';
import '../../constants/staff/pharmacy_text.dart';
import '../../controllers/staff/pharmacy_providers.dart';
import '../../widgets/staff/pharmacy/queue_tile.dart';

/// `/pharmacy/dispense` — prescriptions still to hand over, oldest first; tap one to dispense it.
class PharmacyQueueScreen extends ConsumerWidget {
  const PharmacyQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(
      title: const Text(PharmacyText.pharmacyQueue),
      actions: [
        IconButton(
          tooltip: PharmacyText.dispensedMedicines,
          icon: const Icon(Icons.history_rounded),
          onPressed: () => context.push(StaffPaths.dispensations),
        ),
      ],
    ),
    body: InfiniteList<Prescription>(
      reloadKey: ref.watch(pharmacyVersionProvider),
      load: (page) => ref.read(prescriptionRepositoryProvider).queue(ListQuery(page: page, perPage: 25)),
      empty: const EmptyState(
        icon: Icons.medication_outlined,
        title: PharmacyText.queueIsEmpty,
        message: PharmacyText.queueEmptyHint,
      ),
      itemBuilder: (context, prescription, _) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: QueueTile(
          prescription: prescription,
          onTap: () => context.push(StaffPaths.dispenseFor(prescription.id)),
        ),
      ),
    ),
  );
}
