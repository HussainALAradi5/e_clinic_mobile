import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';

import 'treatment_session_list.dart';

class TreatmentCard extends StatelessWidget {
  const TreatmentCard({super.key, required this.plan});

  final Treatment plan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final next = plan.progress?.nextSession;
    return ExpandableCard(
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(plan.title, style: theme.textTheme.titleMedium)),
              StatusChip(enumName: 'GenericStatus', value: plan.status),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              StatusChip(enumName: 'TreatmentType', value: plan.type),
              if (plan.doctor != null)
                Text(plan.doctor!.fullName, style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 12),
          AppProgressBar(value: plan.completion, height: 8, color: _healthColor(plan.health, scheme)),
          const SizedBox(height: 6),
          Text(
            '${plan.health.label} · ${plan.attended} of ${plan.plannedSessions} attended'
            '${next == null ? '' : ' · next ${ClinicClock.relativeDay(next.scheduledDate)}, ${ClinicClock.wallTime(next.startTime)}'}',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
      details: (_) => TreatmentSessionList(planId: plan.id),
    );
  }
}

/// Colour of the progress bar by how the plan is going (same as the web).
Color _healthColor(ProgressHealth health, ColorScheme scheme) => switch (health) {
  ProgressHealth.onTrack => scheme.primary,
  ProgressHealth.slipping => Colors.amber.shade600,
  ProgressHealth.atRisk => Colors.red.shade600,
  ProgressHealth.done => Colors.green.shade600,
  ProgressHealth.notStarted || ProgressHealth.stopped => scheme.outline,
};
