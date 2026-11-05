import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/staff/approval_action_text.dart';
import '../../utilities/staff/formatters.dart';
import 'staff_providers.dart';

part 'approval_actions_decision.dart';

abstract final class ApprovalActions {
  static Decision refund(WidgetRef ref, Refund refund) => Decision(
    approveConfirm: ConfirmConfig(
      title: ApprovalActionText.refundTitle,
      message: ApprovalActionText.refundMessage(refund.amount.label, refund.patient?.fullName ?? ApprovalActionText.thePatient),
      confirmLabel: ApprovalActionText.approve,
    ),
    approve: (_) => ref.read(refundRepositoryProvider).approve(refund.id),
    approved: ApprovalActionText.refundApproved,
    rejectTitle: ApprovalActionText.refundReject,
    reject: (reason) => ref.read(refundRepositoryProvider).reject(refund.id, reason),
  );

  static Decision expense(WidgetRef ref, Expense expense) => Decision(
    approveConfirm: ConfirmConfig(
      title: ApprovalActionText.expenseTitle,
      message: ApprovalActionText.expenseMessage(expense.amount.label, expense.payeeName ?? expense.description ?? expense.code),
      confirmLabel: ApprovalActionText.approve,
    ),
    approve: (_) => ref.read(expenseRepositoryProvider).approve(expense.id),
    approved: ApprovalActionText.expenseApproved,
    rejectTitle: ApprovalActionText.expenseReject,
    reject: (reason) => ref.read(expenseRepositoryProvider).reject(expense.id, reason),
  );

  /// Booked visits on those days stop the approval; the approver then chooses to cancel them (patients are told).
  static Decision leave(WidgetRef ref, LeaveRequest leave) {
    final name = leave.employee?.fullName ?? ApprovalActionText.thisPerson;
    final repository = ref.read(leaveRepositoryProvider);
    return Decision(
      approveConfirm: ConfirmConfig(
        title: ApprovalActionText.leaveTitle,
        message: ApprovalActionText.leaveMessage(name, leaveDaysLabel(leave)),
        confirmLabel: ApprovalActionText.approve,
      ),
      approve: (context) async {
        try {
          await repository.approve(leave.id);
        } on ApiException catch (error) {
          if (error.code != ErrorCodes.scheduleHasAppointments || !context.mounted) rethrow;
          final cancel = await showConfirmSheet(
            context,
            ConfirmConfig(
              title: ApprovalActionText.leaveHasBookings(name),
              message: ApprovalActionText.leaveCancelBookings,
              confirmLabel: ApprovalActionText.leaveCancelConfirm,
              cancelLabel: ApprovalActionText.keepAsIs,
              danger: true,
            ),
          );
          if (!cancel) throw const ActionCancelled();
          await repository.approve(leave.id, cancelAffected: true);
        }
      },
      approved: ApprovalActionText.leaveApproved,
      rejectTitle: ApprovalActionText.leaveReject,
      reject: (reason) => repository.reject(leave.id, reason),
    );
  }

  static Decision overtime(WidgetRef ref, Attendance day) => Decision(
    approveConfirm: ConfirmConfig(
      title: ApprovalActionText.overtimeTitle,
      message: ApprovalActionText.overtimeMessage(
        day.employee?.fullName ?? ApprovalActionText.staffMember,
        formatMinutes(day.overtimeMinutes),
        ClinicClock.date(day.date),
      ),
      confirmLabel: ApprovalActionText.approve,
    ),
    approve: (_) => ref.read(attendanceRepositoryProvider).approveOvertime(day.id),
    approved: ApprovalActionText.overtimeApproved,
  );

  /// A late excuse or overtime request: approving excuses the minutes or pays them; a rejection needs a reason.
  static Decision staffRequest(WidgetRef ref, StaffRequest request) {
    final name = request.employee?.fullName ?? ApprovalActionText.staffMember;
    final day = request.attendance == null ? '' : ApprovalActionText.onDay(ClinicClock.date(request.attendance!.date));
    final amount = request.details?.amount;
    return Decision(
      approveConfirm: ConfirmConfig(
        title: request.isLate ? ApprovalActionText.lateTitle : ApprovalActionText.payOvertimeTitle,
        message: request.isLate
            ? ApprovalActionText.lateMessage(name, formatMinutes(request.minutes), day, amount?.label)
            : ApprovalActionText.payOvertimeMessage(name, formatMinutes(request.minutes), day, amount?.label),
        confirmLabel: ApprovalActionText.approve,
      ),
      approve: (_) => ref.read(staffRequestRepositoryProvider).approve(request.id),
      approved: request.isLate ? ApprovalActionText.lateExcused : ApprovalActionText.overtimeApproved,
      rejectTitle: request.isLate ? ApprovalActionText.lateReject : ApprovalActionText.overtimeReject,
      reject: (reason) => ref.read(staffRequestRepositoryProvider).reject(request.id, reason),
    );
  }

  /// The reason sheet of a reject; null when the user backed out.
  static Future<String?> askReason(BuildContext context, String title) => showReasonSheet(
    context,
    ConfirmConfig(
      title: title,
      message: ApprovalActionText.rejectReasonHint,
      confirmLabel: ApprovalActionText.reject,
      danger: true,
    ),
  );

  /// After a decision: reload the list and the tab badge.
  static void decided(BuildContext context, WidgetRef ref, String message) {
    ref.read(approvalsVersionProvider.notifier).bump();
    if (context.mounted) AppSnack.success(context, message);
  }
}
