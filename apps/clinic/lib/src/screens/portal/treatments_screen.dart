import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/portal/portal_providers.dart';
import '../../widgets/portal/treatments/treatment_card.dart';

/// `/treatments` — treatment plans with progress and the next session; each opens to its sessions.
class TreatmentsScreen extends ConsumerWidget {
  const TreatmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('My treatments')),
    body: RefreshIndicator(
      onRefresh: () => ref.refresh(treatmentsProvider.future),
      child: AsyncBody(
        value: ref.watch(treatmentsProvider),
        onRetry: () => ref.invalidate(treatmentsProvider),
        data: (plans) => plans.isEmpty
            ? ListView(
                children: const [
                  EmptyState(
                    icon: Icons.self_improvement_rounded,
                    title: 'No treatment plans',
                    message: 'When your doctor plans physiotherapy, infusions or other sessions, they show here.',
                  ),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                itemCount: plans.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, i) => TreatmentCard(plan: plans[i]),
              ),
      ),
    ),
  );
}
