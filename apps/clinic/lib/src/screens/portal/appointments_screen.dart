import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/routes/portal_paths.dart';
import '../../controllers/portal/portal_providers.dart';
import '../../widgets/portal/visits/visit_card.dart';

part 'appointments_screen_view.dart';

/// `/appointments` — upcoming visits (soonest first) with check-in code and cancel; past ones newest first.
class AppointmentsScreen extends ConsumerStatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  ConsumerState<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends ConsumerState<AppointmentsScreen> {
  static const _pageSize = 20;
  var _view = _View.upcoming;

  Future<Paged<Appointment>> _load(int page) {
    final upcoming = _view == _View.upcoming;
    return ref
        .read(appointmentRepositoryProvider)
        .list(
          ListQuery(
            page: page,
            perPage: _pageSize,
            sort: upcoming ? const ['scheduledDate', 'startTime'] : const ['-scheduledDate', '-startTime'],
            filter: upcoming ? upcomingVisits() : pastVisits(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final version = ref.watch(visitsVersionProvider);
    final upcoming = _view == _View.upcoming;
    return Scaffold(
      appBar: AppBar(title: const Text('My visits')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(PortalPaths.book),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Book a visit'),
      ),
      body: InfiniteList<Appointment>(
        reloadKey: (_view, version),
        load: _load,
        header: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: SegmentedButton<_View>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: _View.upcoming, label: Text('Upcoming')),
              ButtonSegment(value: _View.past, label: Text('Past')),
            ],
            selected: {_view},
            onSelectionChanged: (selection) => setState(() => _view = selection.first),
          ),
        ),
        empty: EmptyState(
          icon: upcoming ? Icons.event_available_rounded : Icons.history_rounded,
          title: upcoming ? 'No upcoming visits' : 'No past visits yet',
          message: upcoming ? 'Book a visit and it will show here.' : null,
        ),
        itemBuilder: (context, visit, replace) => VisitCard(visit: visit, onChanged: replace),
      ),
    );
  }
}
