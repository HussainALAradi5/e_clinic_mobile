import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/portal_actions.dart';
import '../application/portal_providers.dart';

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

class _SickLeaveCard extends StatelessWidget {
  const _SickLeaveCard({required this.leave});

  final SickLeave leave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(leave.code, style: muted?.copyWith(fontFamily: 'monospace')),
                const Spacer(),
                Text('Issued ${ClinicClock.dateTime(leave.issuedAt)}', style: muted),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${leave.days} ${leave.days == 1 ? 'day' : 'days'} off',
              style: theme.textTheme.titleLarge?.copyWith(
                decoration: leave.isCancelled ? TextDecoration.lineThrough : null,
              ),
            ),
            Text(
              '${ClinicClock.date(leave.startDate)} – ${ClinicClock.date(leave.endDate)}',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            FactList(
              facts: [
                (label: 'Doctor', value: leave.doctor.fullName),
                (label: 'Reason', value: leave.reason),
                (label: 'Notes', value: leave.notes),
              ],
            ),
            if (leave.isCancelled)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: InfoNote(
                  icon: Icons.block_rounded,
                  text: 'Cancelled by the doctor: ${leave.cancelReason ?? ''}',
                ),
              )
            else ...[
              const SizedBox(height: 12),
              AppButton(
                label: 'Show the code',
                icon: Icons.qr_code_2_rounded,
                variant: ButtonVariant.tonal,
                expand: true,
                onPressed: () => PortalActions.showSickLeaveCode(context, leave),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
