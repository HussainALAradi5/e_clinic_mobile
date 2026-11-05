import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_shell/shell.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/common/common_text.dart';
import '../../../constants/staff/leave_text.dart';
import '../../../controllers/staff/leave_providers.dart';
import '../../../utilities/staff/formatters.dart';
import '../../common/attach_photo_button.dart';

/// One of my leave requests: type, days and dates, status, the manager's note; while open *Withdraw*, and for a
/// draft a certificate photo and *Send*.
class LeaveRequestCard extends ConsumerStatefulWidget {
  const LeaveRequestCard({super.key, required this.leave});

  final LeaveRequest leave;

  @override
  ConsumerState<LeaveRequestCard> createState() => _LeaveRequestCardState();
}

class _LeaveRequestCardState extends ConsumerState<LeaveRequestCard> {
  /// A certificate was attached here (lists do not carry the file count).
  var _attached = false;

  LeaveRequest get leave => widget.leave;

  Future<void> _submit() async {
    await ref.read(leaveRepositoryProvider).submit(leave.id);
    ref.read(leavesVersionProvider.notifier).bump();
  }

  Future<void> _cancel() async {
    await ref.read(leaveRepositoryProvider).cancel(leave.id);
    ref.read(leavesVersionProvider.notifier).bump();
  }

  @override
  Widget build(BuildContext context) {
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
                Expanded(child: Text(leave.leaveType?.name ?? LeaveText.leave, style: theme.textTheme.titleMedium)),
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
              InfoNote(
                icon: Icons.attach_file_rounded,
                text: _attached || (leave.attachmentsCount ?? 0) > 0
                    ? LeaveText.certificateAttached
                    : LeaveText.attachCertificate,
              ),
            ],
            if (canAct && leave.cancellable) ...[
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                runSpacing: 8,
                children: [
                  AppButton(
                    label: CommonText.withdraw,
                    icon: Icons.undo_rounded,
                    variant: ButtonVariant.text,
                    confirm: const ConfirmConfig(
                      title: LeaveText.withdrawThisRequest,
                      confirmLabel: CommonText.withdraw,
                      cancelLabel: CommonText.keep,
                      danger: true,
                    ),
                    onPressed: _cancel,
                  ),
                  if (leave.isDraft) ...[
                    AttachPhotoButton(
                      ownerType: 'leave_request',
                      ownerId: leave.id,
                      category: AttachmentCategory.medicalCertificate,
                      label: LeaveText.certificate,
                      variant: ButtonVariant.text,
                      onUploaded: (_) => setState(() => _attached = true),
                    ),
                    AppButton(
                      label: CommonText.send,
                      icon: Icons.send_rounded,
                      variant: ButtonVariant.tonal,
                      onPressed: _submit,
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
