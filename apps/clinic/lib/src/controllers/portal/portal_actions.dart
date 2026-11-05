import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/billing/fee_text.dart';
import '../../constants/portal/portal_action_text.dart';
import 'portal_providers.dart';

/// Portal steps with their confirmations and messages.
abstract final class PortalActions {
  static Future<void> showVisitCode(BuildContext context, Appointment visit) => showCodeSheet(
    context,
    entity: 'appointment',
    id: visit.id,
    title: PortalActionText.checkInCode,
    lines: [
      '${ClinicClock.day(visit.scheduledDate)}, ${ClinicClock.wallTime(visit.startTime)}',
      visit.doctorName,
      visit.code,
    ],
    hint: PortalActionText.checkInHint,
  );

  static Future<void> showPrescriptionCode(BuildContext context, Prescription rx) => showCodeSheet(
    context,
    entity: 'prescription',
    id: rx.id,
    title: PortalActionText.prescriptionCode,
    lines: [rx.code, PortalActionText.validUntil(ClinicClock.date(rx.validUntil))],
    hint: PortalActionText.prescriptionHint,
  );

  /// The certificate's QR: an employer scans it to check the dates with the clinic (never the reason).
  static Future<void> showSickLeaveCode(BuildContext context, SickLeave leave) => showCodeSheet(
    context,
    entity: 'sick_leave',
    id: leave.id,
    title: PortalActionText.sickLeave(leave.code),
    lines: [
      PortalActionText.sickLeaveDays(leave.days, ClinicClock.date(leave.startDate), ClinicClock.date(leave.endDate)),
      leave.doctor.fullName,
    ],
    hint: PortalActionText.sickLeaveHint,
  );

  /// Asks why, cancels and returns the updated visit; null when the patient kept it.
  static Future<Appointment?> cancelVisit(BuildContext context, WidgetRef ref, Appointment visit) async {
    final reason = await showReasonSheet(
      context,
      ConfirmConfig(
        title: PortalActionText.cancelTitle,
        message: PortalActionText.cancelMessage(
          ClinicClock.day(visit.scheduledDate),
          ClinicClock.wallTime(visit.startTime),
          visit.doctorName,
          FeeText.rules,
        ),
        confirmLabel: PortalActionText.cancelConfirm,
        cancelLabel: PortalActionText.keepIt,
        danger: true,
      ),
      label: PortalActionText.cancelReason,
    );
    if (reason == null) return null;
    try {
      final cancelled = await ref.read(portalRepositoryProvider).cancel(visit.id, reason);
      ref.read(visitsVersionProvider.notifier).bump();
      if (context.mounted) AppSnack.success(context, PortalActionText.cancelled);
      return cancelled;
    } on ApiException catch (error) {
      if (context.mounted) AppSnack.error(context, error);
      return null;
    }
  }
}
