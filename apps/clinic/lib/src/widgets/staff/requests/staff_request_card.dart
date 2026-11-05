import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';

import '../../../constants/common/common_text.dart';
import '../../../constants/staff/staff_request_text.dart';
import '../../../utilities/staff/formatters.dart';
import 'request_tone.dart';

/// One staff request: a coloured edge for its kind (late amber, overtime blue), the day and minutes, what it is
/// worth, both reasons and the decision. [onWithdraw] while it waits (mine); [decision] buttons for HR.
class StaffRequestCard extends StatelessWidget {
  const StaffRequestCard({super.key, required this.request, this.showEmployee = false, this.onWithdraw});

  final StaffRequest request;
  final bool showEmployee;
  final Future<void> Function()? onWithdraw;

  /// What the amount means now: a late excuse saves a deduction, overtime adds pay — once decided, what happened.
  (String, String) _amount(Money amount) => switch ((request.isLate, request.status)) {
    (true, 'approved') => (StaffRequestText.excused, amount.label),
    (true, 'rejected') => (StaffRequestText.deducted, '−${amount.label}'),
    (true, _) => (CommonText.ifNotExcused, '−${amount.label}'),
    (false, 'approved') => (StaffRequestText.paid, '+${amount.label}'),
    (false, 'rejected') => (StaffRequestText.notPaid, amount.label),
    (false, _) => (CommonText.toPay, '+${amount.label}'),
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final tone = RequestTone.of(context, late: request.isLate);
    final day = request.attendance;
    final amount = request.details?.amount;
    final rejected = request.status == 'rejected';
    return Card(
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 5, color: tone),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            showEmployee
                                ? (request.employee?.fullName ?? request.code)
                                : (day == null ? request.code : ClinicClock.date(day.date)),
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        StatusChip(enumName: 'ApprovalStatus', value: request.status),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        StatusChip(enumName: 'StaffRequestType', value: request.type),
                        Text(
                          formatMinutes(request.minutes),
                          style: theme.textTheme.titleMedium?.copyWith(color: tone, fontWeight: FontWeight.w700),
                        ),
                        if (showEmployee && day != null)
                          Text(StaffRequestText.onDay(ClinicClock.date(day.date)), style: theme.textTheme.bodyMedium),
                      ],
                    ),
                    const SizedBox(height: 8),
                    FactList(
                      facts: [
                        if (day != null)
                          (
                            label: StaffRequestText.inOut,
                            value: '${clockTime(day.checkInAt)} – ${clockTime(day.checkOutAt)}',
                          ),
                        if (amount != null) (label: _amount(amount).$1, value: _amount(amount).$2),
                        (label: CommonText.reason, value: request.reason ?? CommonText.noReasonGiven),
                        (label: StaffRequestText.code, value: request.code),
                      ],
                    ),
                    if (request.reviewedAt != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (rejected ? theme.colorScheme.error : const Color(0xFF16A34A)).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              rejected ? Icons.cancel_rounded : Icons.verified_rounded,
                              size: 20,
                              color: rejected ? theme.colorScheme.error : const Color(0xFF16A34A),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${rejected ? 'Rejected' : StaffRequestText.approved} by ${request.reviewedBy?.fullName ?? 'HR'} · '
                                    '${ClinicClock.dateTime(request.reviewedAt!)}',
                                    style: theme.textTheme.bodySmall?.copyWith(color: muted),
                                  ),
                                  if (request.reviewReason != null)
                                    Text('“${request.reviewReason}”', style: theme.textTheme.bodyMedium),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (onWithdraw != null && request.isPending) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: AppButton(
                          label: CommonText.withdraw,
                          icon: Icons.undo_rounded,
                          variant: ButtonVariant.text,
                          onPressed: onWithdraw,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
