import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_features/features.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/leave_providers.dart';
import '../../utils/formatters.dart';

/// One of my leave requests: type, days and dates, status, the manager's note, and *Send* (draft) or *Withdraw*
/// while it is still open.
class LeaveRequestCard extends ConsumerWidget {
  const LeaveRequestCard({super.key, required this.leave});

  final LeaveRequest leave;

  Future<void> _submit(WidgetRef ref) async {
    await ref.read(leaveRepositoryProvider).submit(leave.id);
    ref.read(leavesVersionProvider.notifier).bump();
  }

  Future<void> _cancel(WidgetRef ref) async {
    await ref.read(leaveRepositoryProvider).cancel(leave.id);
    ref.read(leavesVersionProvider.notifier).bump();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final canAct = ref.watch(accessProvider).can('leaves.write & leaves.request');
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(leave.leaveType?.name ?? 'Leave', style: theme.textTheme.titleMedium)),
                StatusChip(enumName: 'ApprovalStatus', value: leave.status),
              ],
            ),
            const SizedBox(height: 2),
            Text(leaveDaysLabel(leave), style: theme.textTheme.bodyMedium),
            if (leave.reason != null) Text(leave.reason!, style: theme.textTheme.bodySmall?.copyWith(color: muted)),
            if (leave.reviewNotes != null) ...[
              const SizedBox(height: 6),
              InfoNote(icon: Icons.comment_outlined, text: 'Manager: ${leave.reviewNotes}'),
            ],
            if (leave.isDraft) ...[
              const SizedBox(height: 6),
              const InfoNote(
                icon: Icons.attach_file_rounded,
                text: 'Attach the certificate on the clinic website, then send it to your manager.',
              ),
            ],
            if (canAct && leave.cancellable) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                    label: 'Withdraw',
                    icon: Icons.undo_rounded,
                    variant: ButtonVariant.text,
                    confirm: const ConfirmConfig(
                      title: 'Withdraw this request?',
                      confirmLabel: 'Withdraw',
                      cancelLabel: 'Keep',
                      danger: true,
                    ),
                    onPressed: () => _cancel(ref),
                  ),
                  if (leave.isDraft) ...[
                    const SizedBox(width: 8),
                    AppButton(
                      label: 'Send',
                      icon: Icons.send_rounded,
                      variant: ButtonVariant.tonal,
                      onPressed: () => _submit(ref),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
