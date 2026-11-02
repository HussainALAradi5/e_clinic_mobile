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

part 'staff_requests_screen_ask_button.dart';
part 'staff_requests_screen_askable_day_card.dart';

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
