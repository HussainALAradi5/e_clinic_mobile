import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'portal_providers.dart';

/// Portal steps with their confirmations and messages.
abstract final class PortalActions {
  static Future<void> showVisitCode(BuildContext context, Appointment visit) => showCodeSheet(
    context,
    entity: 'appointment',
    id: visit.id,
    title: 'Check-in code',
    lines: ['${ClinicClock.day(visit.scheduledDate)}, ${visit.startTime}', visit.doctorName, visit.code],
    hint: 'Show this at the front desk when you arrive. It works only for this visit.',
  );

  static Future<void> showPrescriptionCode(BuildContext context, Prescription rx) => showCodeSheet(
    context,
    entity: 'prescription',
    id: rx.id,
    title: 'Prescription code',
    lines: [rx.code, 'Valid until ${ClinicClock.date(rx.validUntil)}'],
    hint: 'Show this at the clinic pharmacy to collect your medicines.',
  );

  /// The certificate's QR: an employer scans it to check the dates with the clinic (never the reason).
  static Future<void> showSickLeaveCode(BuildContext context, SickLeave leave) => showCodeSheet(
    context,
    entity: 'sick_leave',
    id: leave.id,
    title: 'Sick leave ${leave.code}',
    lines: [
      '${leave.days} ${leave.days == 1 ? 'day' : 'days'}: ${ClinicClock.date(leave.startDate)} – ${ClinicClock.date(leave.endDate)}',
      leave.doctor.fullName,
    ],
    hint: 'Your employer or school scans this to check the certificate with the clinic. It shows the dates only.',
  );

  /// Asks why, cancels and returns the updated visit; null when the patient kept it.
  static Future<Appointment?> cancelVisit(BuildContext context, WidgetRef ref, Appointment visit) async {
    final reason = await showReasonSheet(
      context,
      ConfirmConfig(
        title: 'Cancel this visit?',
        message:
            '${ClinicClock.day(visit.scheduledDate)} at ${visit.startTime} with ${visit.doctorName}. '
            'Online cancellation closes 3 days before the start; after that, call reception.',
        confirmLabel: 'Cancel visit',
        cancelLabel: 'Keep it',
        danger: true,
      ),
      label: 'Why are you cancelling?',
    );
    if (reason == null) return null;
    try {
      final cancelled = await ref.read(portalRepositoryProvider).cancel(visit.id, reason);
      ref.read(visitsVersionProvider.notifier).bump();
      if (context.mounted) AppSnack.success(context, 'Your visit is cancelled.');
      return cancelled;
    } on ApiException catch (error) {
      if (context.mounted) AppSnack.error(context, error);
      return null;
    }
  }
}
