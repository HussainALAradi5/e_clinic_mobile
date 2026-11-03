import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/routes/portal_paths.dart';
import '../../controllers/portal/portal_providers.dart';
import '../../widgets/common/enum_filter_chips.dart';
import '../../widgets/portal/visits/visit_card.dart';

/// `/appointments` — my visits, coloured by timing, with a filter: All · Coming · Today · Past · Missed. Coming and
/// today run soonest first; all, past and missed newest first. Visits ahead offer the check-in code and cancel.
class AppointmentsScreen extends ConsumerStatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  ConsumerState<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends ConsumerState<AppointmentsScreen> {
  static const _pageSize = 20;
  VisitTiming? _timing;

  Future<Paged<Appointment>> _load(int page) {
    final soonestFirst = _timing == VisitTiming.coming || _timing == VisitTiming.today;
    return ref
        .read(appointmentRepositoryProvider)
        .list(
          ListQuery(
            page: page,
            perPage: _pageSize,
            sort: soonestFirst ? const ['scheduledDate', 'startTime'] : const ['-scheduledDate', '-startTime'],
          ),
          timing: _timing,
        );
  }

  @override
  Widget build(BuildContext context) {
    final version = ref.watch(visitsVersionProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My visits')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(PortalPaths.book),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Book a visit'),
      ),
      body: InfiniteList<Appointment>(
        reloadKey: (_timing, version),
        load: _load,
        header: Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 16),
          child: EnumFilterChips(
            enumName: 'VisitTiming',
            values: VisitTiming.filters,
            selected: _timing,
            onSelected: (t) => setState(() => _timing = t),
          ),
        ),
        empty: EmptyState(
          icon: _timing == VisitTiming.past || _timing == VisitTiming.missed
              ? Icons.history_rounded
              : Icons.event_available_rounded,
          title: switch (_timing) {
            VisitTiming.coming => 'No upcoming visits',
            VisitTiming.today => 'No visits today',
            VisitTiming.past => 'No past visits yet',
            VisitTiming.missed => 'No missed visits',
            _ => 'No visits yet',
          },
          message: _timing == null || _timing == VisitTiming.coming ? 'Book a visit and it will show here.' : null,
        ),
        itemBuilder: (context, visit, replace) => VisitCard(visit: visit, onChanged: replace),
      ),
    );
  }
}
