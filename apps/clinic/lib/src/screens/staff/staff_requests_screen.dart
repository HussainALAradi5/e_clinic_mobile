import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/staff/request_providers.dart';
import '../../utilities/staff/formatters.dart';
import '../../widgets/staff/requests/ask_request_sheet.dart';
import '../../widgets/staff/requests/request_tone.dart';
import '../../widgets/staff/requests/staff_request_card.dart';

/// `/hr/requests` — my days I can still ask about (late in amber, overtime in blue: tap to ask HR, with an optional
/// reason), then my requests with HR's decision and reason. HR decides them under Approvals.
class StaffRequestsScreen extends ConsumerWidget {
  const StaffRequestsScreen({super.key});

  Future<void> _ask(BuildContext context, WidgetRef ref, Attendance day, String type) async {
    final created = await showAskRequestSheet(context, day: day, type: type);
    if (created == null) return;
    ref.read(requestsVersionProvider.notifier).bump();
    if (context.mounted) AppSnack.success(context, 'Sent to HR — ${created.code}.');
  }

  Future<void> _withdraw(BuildContext context, WidgetRef ref, StaffRequest request) async {
    final confirmed = await showConfirmSheet(
      context,
      ConfirmConfig(
        title: 'Withdraw ${request.code}?',
        message: 'HR will not decide it. You can ask about the same day again later.',
        confirmLabel: 'Withdraw',
        danger: true,
      ),
    );
    if (!confirmed) return;
    await ref.read(staffRequestRepositoryProvider).cancel(request.id);
    ref.read(requestsVersionProvider.notifier).bump();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('My requests')),
    body: RefreshIndicator(
      onRefresh: () async {
        ref.read(requestsVersionProvider.notifier).bump();
        await ref.read(myRequestsProvider.future);
      },
      child: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          const SectionHeader('Ask HR about a day'),
          ref
              .watch(askableDaysProvider)
              .when(
                loading: () => const SkeletonList(count: 1, height: 96),
                error: (error, _) => ErrorState(error: error, onRetry: () => ref.invalidate(askableDaysProvider)),
                data: (days) => days.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: InfoNote(
                          icon: Icons.sentiment_satisfied_rounded,
                          text:
                              'Nothing to ask about: no late arrivals or unpaid overtime in the last 31 days, or HR '
                              'has these requests switched off.',
                        ),
                      )
                    : Column(
                        children: [
                          for (final a in days)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                              child: _AskableDayCard(day: a, onAsk: (type) => _ask(context, ref, a.attendance, type)),
                            ),
                        ],
                      ),
              ),
          const SectionHeader('My requests'),
          ref
              .watch(myRequestsProvider)
              .when(
                loading: () => const SkeletonList(count: 2, height: 140),
                error: (error, _) => ErrorState(error: error, onRetry: () => ref.invalidate(myRequestsProvider)),
                data: (requests) => requests.isEmpty
                    ? const EmptyState(
                        icon: Icons.fact_check_outlined,
                        title: 'No requests yet',
                        message: 'Ask HR to excuse a late arrival or to pay your overtime from a day above.',
                      )
                    : Column(
                        children: [
                          for (final r in requests)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                              child: StaffRequestCard(request: r, onWithdraw: () => _withdraw(context, ref, r)),
                            ),
                        ],
                      ),
              ),
        ],
      ),
    ),
  );
}

/// A day with late minutes and / or overtime: one coloured button per kind of request it still allows.
class _AskableDayCard extends StatelessWidget {
  const _AskableDayCard({required this.day, required this.onAsk});

  final AskableDay day;
  final void Function(String type) onAsk;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final a = day.attendance;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: Text(ClinicClock.day(a.date), style: theme.textTheme.titleSmall)),
                Text(
                  '${clockTime(a.checkInAt)} – ${clockTime(a.checkOutAt)}',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final type in day.types) ...[
              _AskButton(
                late: type == StaffRequestTypes.lateExcuse,
                minutes: type == StaffRequestTypes.lateExcuse ? a.lateMinutes : a.overtimeMinutes,
                onTap: () => onAsk(type),
              ),
              const SizedBox(height: 6),
            ],
          ],
        ),
      ),
    );
  }
}

class _AskButton extends StatelessWidget {
  const _AskButton({required this.late, required this.minutes, required this.onTap});

  final bool late;
  final int minutes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tone = RequestTone.of(context, late: late);
    final style = Theme.of(context).textTheme.bodyLarge?.copyWith(color: tone);
    return Material(
      color: RequestTone.soft(context, late: late),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Icon(RequestTone.icon(late: late), color: tone),
              const SizedBox(width: 10),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: late ? 'Late ' : 'Overtime ',
                    children: [
                      TextSpan(
                        text: formatMinutes(minutes),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(text: late ? ' · ask to excuse' : ' · ask to pay'),
                    ],
                  ),
                  style: style,
                ),
              ),
              Icon(Icons.arrow_forward_rounded, color: tone),
            ],
          ),
        ),
      ),
    );
  }
}
