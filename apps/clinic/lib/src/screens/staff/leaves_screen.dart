import 'package:e_clinic_shell/shell.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/routes/staff_paths.dart';
import '../../controllers/staff/leave_providers.dart';
import '../../widgets/staff/leaves/balance_card.dart';
import '../../widgets/staff/leaves/leave_request_card.dart';

/// `/hr/leaves` — my days left this year and my requests; *Request leave* opens the form.
class LeavesScreen extends ConsumerWidget {
  const LeavesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canRequest = ref.watch(accessProvider).can('leaves.create & leaves.request');
    return Scaffold(
      appBar: AppBar(title: const Text('My leave')),
      floatingActionButton: canRequest
          ? FloatingActionButton.extended(
              onPressed: () => context.push(StaffPaths.newLeave),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Request leave'),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () async {
          ref
            ..invalidate(myBalancesProvider)
            ..invalidate(myLeavesProvider);
          await ref.read(myLeavesProvider.future);
        },
        child: ListView(
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            const SectionHeader('This year'),
            ref
                .watch(myBalancesProvider)
                .when(
                  loading: () => const SkeletonList(count: 1, height: 110),
                  error: (error, _) => ErrorState(error: error, onRetry: () => ref.invalidate(myBalancesProvider)),
                  data: (balances) => balances.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: InfoNote(
                            icon: Icons.info_outline_rounded,
                            text: 'No leave balances set up for you yet.',
                          ),
                        )
                      : SizedBox(
                          height: 140,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: balances.length,
                            separatorBuilder: (_, _) => const SizedBox(width: 8),
                            itemBuilder: (_, i) => BalanceCard(balance: balances[i]),
                          ),
                        ),
                ),
            const SectionHeader('My requests'),
            ref
                .watch(myLeavesProvider)
                .when(
                  loading: () => const SkeletonList(count: 2, height: 110),
                  error: (error, _) => ErrorState(error: error, onRetry: () => ref.invalidate(myLeavesProvider)),
                  data: (leaves) => leaves.isEmpty
                      ? const EmptyState(icon: Icons.beach_access_outlined, title: 'No requests yet')
                      : Column(
                          children: [
                            for (final leave in leaves)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                                child: LeaveRequestCard(leave: leave),
                              ),
                          ],
                        ),
                ),
          ],
        ),
      ),
    );
  }
}
