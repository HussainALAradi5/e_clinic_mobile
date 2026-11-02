import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/portal/portal_actions.dart';
import '../../controllers/portal/portal_providers.dart';

part 'sick_leaves_screen_sick_leave_card.dart';

/// `/sick-leaves` — every sick leave the clinic gave me, newest first: the days off, the doctor, the reason, and the
/// QR code an employer or school scans to check it. Cancelled ones stay listed, marked.
class SickLeavesScreen extends ConsumerWidget {
  const SickLeavesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('My sick leaves')),
    body: RefreshIndicator(
      onRefresh: () => ref.refresh(sickLeavesProvider.future),
      child: AsyncBody(
        value: ref.watch(sickLeavesProvider),
        onRetry: () => ref.invalidate(sickLeavesProvider),
        data: (list) => list.isEmpty
            ? ListView(
                children: const [
                  EmptyState(
                    icon: Icons.sick_outlined,
                    title: 'No sick leaves',
                    message: 'Certificates your doctor gives you show here, with a code your employer can check.',
                  ),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _SickLeaveCard(leave: list[i]),
              ),
      ),
    ),
  );
}
