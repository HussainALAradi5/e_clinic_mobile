import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/portal_providers.dart';

/// `/treatments` — treatment plans with progress and the next session; each opens to its sessions.
class TreatmentsScreen extends ConsumerWidget {
  const TreatmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('My treatments')),
    body: RefreshIndicator(
      onRefresh: () => ref.refresh(treatmentsProvider.future),
      child: AsyncBody(
        value: ref.watch(treatmentsProvider),
        onRetry: () => ref.invalidate(treatmentsProvider),
        data: (plans) => plans.isEmpty
            ? ListView(
                children: const [
                  EmptyState(
                    icon: Icons.self_improvement_rounded,
                    title: 'No treatment plans',
                    message: 'When your doctor plans physiotherapy, infusions or other sessions, they show here.',
                  ),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                itemCount: plans.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _TreatmentCard(plan: plans[i]),
              ),
      ),
    ),
  );
}

class _TreatmentCard extends StatelessWidget {
  const _TreatmentCard({required this.plan});

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
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: plan.completion,
              minHeight: 8,
              color: _healthColor(plan.health, scheme),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${plan.health.label} · ${plan.attended} of ${plan.plannedSessions} attended'
            '${next == null ? '' : ' · next ${ClinicClock.relativeDay(next.scheduledDate)}, ${next.startTime}'}',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
      details: (_) => _Sessions(planId: plan.id),
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

class _Sessions extends ConsumerWidget {
  const _Sessions({required this.planId});

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
