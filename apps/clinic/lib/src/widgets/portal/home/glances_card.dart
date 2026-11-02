import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes/portal_paths.dart';
import '../../../controllers/portal/portal_providers.dart';

/// One line per area with what is waiting there; a sun dot marks what needs the patient.
class GlancesCard extends ConsumerWidget {
  const GlancesCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final glances = ref.watch(glancesProvider);
    return glances.when(
      loading: () => const SkeletonList(count: 4, height: 64),
      error: (error, _) => ErrorState(error: error, onRetry: () => ref.invalidate(glancesProvider)),
      data: (g) {
        final treatment = g.treatment;
        final next = treatment?.progress?.nextSession;
        final result = g.latestResult;
        final rows = [
          (
            icon: Icons.self_improvement_rounded,
            label: 'Treatments',
            detail: treatment == null
                ? 'No treatment plan running'
                : next != null
                ? '${treatment.title}: next ${ClinicClock.relativeDay(next.scheduledDate)}, ${next.startTime}'
                : '${treatment.title}: ${treatment.attended} of ${treatment.plannedSessions} sessions',
            flag: false,
            path: PortalPaths.treatments,
            push: true,
          ),
          (
            icon: Icons.medication_outlined,
            label: 'Prescriptions',
            detail: g.toCollect > 0 ? '${g.toCollect} to collect at the pharmacy' : 'Nothing to collect',
            flag: g.toCollect > 0,
            path: PortalPaths.prescriptions,
            push: true,
          ),
          (
            icon: Icons.science_outlined,
            label: 'Results',
            detail: result == null
                ? 'No results yet'
                : '${result.description}${result.completedAt == null ? '' : ', ${ClinicClock.ago(result.completedAt!)}'}',
            flag: false,
            path: PortalPaths.results,
            push: false,
          ),
          (
            icon: Icons.receipt_long_outlined,
            label: 'Invoices',
            detail: g.due.isPositive ? '${g.due.label} to pay' : 'Nothing to pay',
            flag: g.due.isPositive,
            path: PortalPaths.invoices,
            push: false,
          ),
        ];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  if (i > 0) const Divider(height: 1, indent: 64),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    shape: const RoundedRectangleBorder(),
                    leading: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(rows[i].icon, color: Theme.of(context).colorScheme.primary),
                        if (rows[i].flag)
                          Positioned(
                            right: -3,
                            top: -3,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(color: BrandColors.sun, shape: BoxShape.circle),
                            ),
                          ),
                      ],
                    ),
                    title: Text(rows[i].label, style: Theme.of(context).textTheme.titleSmall),
                    subtitle: Text(rows[i].detail, maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      if (rows[i].push) {
                        context.push(rows[i].path);
                      } else {
                        context.go(rows[i].path);
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
