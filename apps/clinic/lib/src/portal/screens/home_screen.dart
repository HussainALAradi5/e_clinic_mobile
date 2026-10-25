import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_features/features.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/portal_actions.dart';
import '../application/portal_providers.dart';
import '../portal_paths.dart';
import '../widgets/visit_card.dart';

/// `/` — the next visit as a ticket with its check-in code, then one line per area with what is waiting.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref
      ..invalidate(nextVisitsProvider)
      ..invalidate(glancesProvider)
      ..invalidate(unreadCountProvider);
    await ref.read(nextVisitsProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final visits = ref.watch(nextVisitsProvider);
    final unread = ref.watch(unreadCountProvider).value ?? 0;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _refresh(ref),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              GreetingHeader(
                firstName: user?.firstName ?? '',
                trailing: IconButton(
                  tooltip: unread > 0 ? '$unread unread messages' : 'Messages',
                  onPressed: () => context.push(PortalPaths.messages),
                  icon: Badge(
                    isLabelVisible: unread > 0,
                    label: Text('$unread'),
                    child: const Icon(Icons.notifications_none_rounded),
                  ),
                ),
              ),
              visits.when(
                loading: () => const SkeletonList(count: 1, height: 190),
                error: (error, _) => ErrorState(error: error, onRetry: () => ref.invalidate(nextVisitsProvider)),
                data: (list) => list.isEmpty
                    ? const _NoVisitCard()
                    : Column(
                        children: [
                          _NextVisitTicket(visit: list.first),
                          for (final later in list.skip(1))
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                              child: VisitCard(visit: later),
                            ),
                        ],
                      ),
              ),
              if (visits.value?.isNotEmpty ?? false)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: OutlinedButton.icon(
                    onPressed: () => context.push(PortalPaths.book),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Book another visit'),
                  ),
                ),
              const SectionHeader('At a glance'),
              const _Glances(),
            ],
          ),
        ),
      ),
    );
  }
}

/// The next visit as a pine ticket: when, with whom, the check-in code.
class _NextVisitTicket extends ConsumerWidget {
  const _NextVisitTicket({required this.visit});

  final Appointment visit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    const onPine = Colors.white;
    const soft = Color(0xFFC6F0E8);
    final parts = ClinicClock.parts(visit.scheduledDate);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: dark ? BrandColors.pineDeep : BrandColors.pine,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Your next visit', style: theme.textTheme.labelLarge?.copyWith(color: soft)),
                const Spacer(),
                if (visit.status == AppointmentStatus.pending)
                  const _Pill(text: 'Awaiting confirmation', color: BrandColors.sun, textColor: Color(0xFF3D2A00))
                else
                  const _Pill(text: 'Confirmed', color: Color(0x33FFFFFF), textColor: onPine),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${parts.day}',
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: onPine,
                    fontWeight: FontWeight.w700,
                    height: 0.9,
                    letterSpacing: -1.5,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${parts.weekday} · ${parts.month}',
                        style: theme.textTheme.titleMedium?.copyWith(color: onPine),
                      ),
                      Text(
                        visit.startTime,
                        style: theme.textTheme.titleLarge?.copyWith(color: onPine, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.medical_services_outlined, color: soft, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(visit.doctorName, style: theme.textTheme.bodyLarge?.copyWith(color: onPine)),
                ),
              ],
            ),
            if (visit.room != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.meeting_room_outlined, color: soft, size: 18),
                  const SizedBox(width: 8),
                  Text(visit.room!.name, style: theme.textTheme.bodyMedium?.copyWith(color: soft)),
                ],
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: BrandColors.pine),
                    onPressed: () => PortalActions.showVisitCode(context, visit),
                    icon: const Icon(Icons.qr_code_2_rounded),
                    label: const Text('Check-in code'),
                  ),
                ),
                if (visit.status.cancellable) ...[
                  const SizedBox(width: 8),
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: soft),
                    onPressed: () => PortalActions.cancelVisit(context, ref, visit),
                    child: const Text('Cancel'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.color, required this.textColor});

  final String text;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(999)),
    child: Text(
      text,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(color: textColor, fontWeight: FontWeight.w600),
    ),
  );
}

class _NoVisitCard extends StatelessWidget {
  const _NoVisitCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('No visits booked', style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                'Pick a doctor and a free time — the clinic confirms your booking.',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => context.push(PortalPaths.book),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Book a visit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One line per area with what is waiting there; a sun dot marks what needs the patient.
class _Glances extends ConsumerWidget {
  const _Glances();

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
