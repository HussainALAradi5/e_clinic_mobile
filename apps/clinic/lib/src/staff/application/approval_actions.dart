import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/formatters.dart';
import 'staff_providers.dart';

/// One request waiting for a decision: what the approve confirmation says, and the two server calls.
/// The buttons ask (confirm / reason) before they lock, so the spinner covers only the call.
class Decision {
  const Decision({
    required this.approveConfirm,
    required this.approve,
    required this.approved,
    this.rejectTitle = 'Reject this request?',
    this.reject,
  });

  final ConfirmConfig approveConfirm;

  /// May ask a follow-up question when the server needs one (leave over booked days).
  final Future<void> Function(BuildContext context) approve;
  final String approved;
  final String rejectTitle;

  /// Null where there is nothing to reject (unapproved overtime is simply not paid).
  final Future<Object?> Function(String reason)? reject;
}

abstract final class ApprovalActions {
  static Decision refund(WidgetRef ref, Refund refund) => Decision(
    approveConfirm: ConfirmConfig(
      title: 'Approve this refund?',
      message:
          '${refund.amount.label} to ${refund.patient?.fullName ?? 'the patient'}. The cashier can then pay it out.',
      confirmLabel: 'Approve',
    ),
    approve: (_) => ref.read(refundRepositoryProvider).approve(refund.id),
    approved: 'Refund approved.',
    rejectTitle: 'Reject this refund?',
    reject: (reason) => ref.read(refundRepositoryProvider).reject(refund.id, reason),
  );

  static Decision expense(WidgetRef ref, Expense expense) => Decision(
    approveConfirm: ConfirmConfig(
      title: 'Approve this expense?',
      message: '${expense.amount.label} — ${expense.payeeName ?? expense.description ?? expense.code}.',
      confirmLabel: 'Approve',
    ),
    approve: (_) => ref.read(expenseRepositoryProvider).approve(expense.id),
    approved: 'Expense approved.',
    rejectTitle: 'Reject this expense?',
    reject: (reason) => ref.read(expenseRepositoryProvider).reject(expense.id, reason),
  );

  /// Booked visits on those days stop the approval; the approver then chooses to cancel them (patients are told).
  static Decision leave(WidgetRef ref, LeaveRequest leave) {
    final name = leave.employee?.fullName ?? 'this person';
    final repository = ref.read(leaveRepositoryProvider);
    return Decision(
      approveConfirm: ConfirmConfig(
        title: 'Approve this leave?',
        message: '$name, ${leaveDaysLabel(leave)}. The days leave their balance and their schedule is blocked.',
        confirmLabel: 'Approve',
      ),
      approve: (context) async {
        try {
          await repository.approve(leave.id);
        } on ApiException catch (error) {
          if (error.code != ErrorCodes.scheduleHasAppointments || !context.mounted) rethrow;
          final cancel = await showConfirmSheet(
            context,
            ConfirmConfig(
              title: '$name has bookings on those days',
              message: 'Approve and cancel those bookings? The patients are told and can book again.',
              confirmLabel: 'Approve and cancel bookings',
              cancelLabel: 'Keep as it is',
              danger: true,
            ),
          );
          if (!cancel) throw const ActionCancelled();
          await repository.approve(leave.id, cancelAffected: true);
        }
      },
      approved: 'Leave approved.',
      rejectTitle: 'Reject this leave?',
      reject: (reason) => repository.reject(leave.id, reason),
    );
  }

  static Decision overtime(WidgetRef ref, Attendance day) => Decision(
    approveConfirm: ConfirmConfig(
      title: 'Approve the overtime?',
      message:
          '${day.employee?.fullName ?? 'Staff member'}: ${formatMinutes(day.overtimeMinutes)} on '
          '${ClinicClock.date(day.date)}. It is paid with the month\'s payroll.',
      confirmLabel: 'Approve',
    ),
    approve: (_) => ref.read(attendanceRepositoryProvider).approveOvertime(day.id),
    approved: 'Overtime approved.',
  );

  /// The reason sheet of a reject; null when the user backed out.
  static Future<String?> askReason(BuildContext context, String title) => showReasonSheet(
    context,
    ConfirmConfig(
      title: title,
      message: 'The person who asked sees your reason.',
      confirmLabel: 'Reject',
      danger: true,
    ),
  );

  /// After a decision: reload the list and the tab badge.
  static void decided(BuildContext context, WidgetRef ref, String message) {
    ref.read(approvalsVersionProvider.notifier).bump();
    if (context.mounted) AppSnack.success(context, message);
  }
}
