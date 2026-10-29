import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/portal_providers.dart';

class TreatmentSessionList extends ConsumerWidget {
  const TreatmentSessionList({super.key, required this.planId});

  final String planId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return AsyncBody(
      value: ref.watch(treatmentSessionsProvider(planId)),
      onRetry: () => ref.invalidate(treatmentSessionsProvider(planId)),
      loading: const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      data: (sessions) => sessions.isEmpty
          ? const Padding(padding: EdgeInsets.all(16), child: Text('No sessions booked yet.'))
          : Column(
              children: [
                for (final s in sessions)
                  ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 14,
                      child: Text('${s.sessionNumber}', style: theme.textTheme.labelSmall),
                    ),
                    title: Text('${ClinicClock.day(s.scheduledDate)}, ${s.startTime}'),
                    subtitle: s.provider == null ? null : Text(s.provider!.fullName),
                    trailing: StatusChip(enumName: 'AppointmentStatus', value: s.status),
                  ),
              ],
            ),
    );
  }
}
