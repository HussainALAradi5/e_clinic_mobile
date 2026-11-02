import 'package:e_clinic_shell/shell.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/routes/portal_paths.dart';
import '../../controllers/portal/portal_providers.dart';
import '../../widgets/portal/home/glances_card.dart';
import '../../widgets/portal/home/next_visit_ticket.dart';
import '../../widgets/portal/home/no_visit_card.dart';
import '../../widgets/portal/visits/visit_card.dart';

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
                    ? const NoVisitCard()
                    : Column(
                        children: [
                          NextVisitTicket(visit: list.first),
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
              const GlancesCard(),
            ],
          ),
        ),
      ),
    );
  }
}
