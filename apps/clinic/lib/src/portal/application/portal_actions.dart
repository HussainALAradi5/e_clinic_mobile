import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

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

  /// Asks why, cancels and returns the updated visit; null when the patient kept it.
  static Future<Appointment?> cancelVisit(BuildContext context, WidgetRef ref, Appointment visit) async {
    final reason = await showReasonSheet(
      context,
      ConfirmConfig(
        title: 'Cancel this visit?',
        message:
            '${ClinicClock.day(visit.scheduledDate)} at ${visit.startTime} with ${visit.doctorName}. '
            'Online cancellation closes 2 hours before the start.',
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

  /// Opens a result file in the phone's viewer through a short-lived signed link.
  static Future<void> openFile(WidgetRef ref, Attachment file) async {
    final link = await ref.read(attachmentRepositoryProvider).downloadLink(file.id);
    if (!await launchUrl(Uri.parse(link.url), mode: LaunchMode.externalApplication)) {
      throw const ApiException(
        status: 0,
        code: ErrorCodes.unexpected,
        message: 'No app on this phone can open the file.',
      );
    }
  }
}
