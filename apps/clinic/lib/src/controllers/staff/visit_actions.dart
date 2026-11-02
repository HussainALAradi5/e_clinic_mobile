import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../widgets/staff/visits/complete_sheet.dart';
import 'staff_providers.dart';

part 'visit_actions_visit_action.dart';

abstract final class VisitActions {
  /// The confirmation a step needs before it runs (only no-show: it cannot be undone).
  static ConfirmConfig? confirmFor(VisitAction action, Appointment visit) => action == VisitAction.noShow
      ? ConfirmConfig(
          title: 'Mark as no-show?',
          message: '${_who(visit)}. The patient did not come; this cannot be undone.',
          confirmLabel: 'No show',
          danger: true,
        )
      : null;

  /// Calls the server for [action] and returns the updated booking. Ask first with [confirmFor] / [askFollowUp]
  /// (the buttons do this before they lock); [followUpInDays] goes with *Complete*.
  static Future<Appointment> run(
    BuildContext context,
    WidgetRef ref,
    VisitAction action,
    Appointment visit, {
    int? followUpInDays,
  }) async {
    final repository = ref.read(appointmentRepositoryProvider);
    final updated = await switch (action) {
      VisitAction.checkIn => repository.checkIn(visit.id),
      VisitAction.start => repository.start(visit.id),
      VisitAction.confirm => repository.confirm(visit.id),
      VisitAction.complete => repository.complete(visit.id, followUpInDays: followUpInDays),
      VisitAction.noShow => repository.noShow(visit.id),
    };
    ref.read(scheduleVersionProvider.notifier).bump();
    if (context.mounted) AppSnack.success(context, _done(action, visit));
    return updated;
  }

  /// The whole step from a menu (no button to lock): confirmation or follow-up question, then the call.
  static Future<void> runFromMenu(BuildContext context, WidgetRef ref, VisitAction action, Appointment visit) async {
    try {
      final confirm = confirmFor(action, visit);
      if (confirm != null && !await showConfirmSheet(context, confirm)) return;
      int? followUp;
      if (action == VisitAction.complete) {
        if (!context.mounted) return;
        final answer = await askFollowUp(context, visit);
        if (answer == null) return;
        followUp = answer == 0 ? null : answer;
      }
      if (context.mounted) await run(context, ref, action, visit, followUpInDays: followUp);
    } on ActionCancelled {
      // Backed out.
    } catch (error) {
      if (context.mounted) AppSnack.error(context, error);
    }
  }

  static String _who(Appointment visit) => '${visit.patientName}, ${visit.startTime}';

  static String _done(VisitAction action, Appointment visit) => switch (action) {
    VisitAction.checkIn => '${visit.patientName} is checked in.',
    VisitAction.start => 'Visit started.',
    VisitAction.complete => 'Visit completed and charged.',
    VisitAction.confirm => 'Booking confirmed.',
    VisitAction.noShow => 'Marked as no-show.',
  };

  /// Null = cancelled, 0 = no follow-up, otherwise days until the suggested next visit.
  static Future<int?> askFollowUp(BuildContext context, Appointment visit) => showModalBottomSheet<int>(
    context: context,
    builder: (_) => CompleteSheet(who: _who(visit)),
  );
}
