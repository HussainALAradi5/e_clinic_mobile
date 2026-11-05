import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/routes/portal_paths.dart';
import '../../constants/common/common_text.dart';
import '../../constants/portal/visit_text.dart';
import '../../controllers/portal/portal_providers.dart';
import '../../widgets/common/date_range_chip.dart';
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
  DateTimeRange? _dates;

  Future<Paged<Appointment>> _load(int page) {
    final soonestFirst = _timing == VisitTiming.coming || _timing == VisitTiming.today;
    return ref
        .read(appointmentRepositoryProvider)
        .list(
          ListQuery(
            dateField: 'scheduled_date',
            dateFrom: _dates == null ? null : ClinicClock.isoDate(_dates!.start),
            dateTo: _dates == null ? null : ClinicClock.isoDate(_dates!.end),
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
      appBar: AppBar(title: const Text(VisitText.myVisits)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(PortalPaths.book),
        icon: const Icon(Icons.add_rounded),
        label: const Text(CommonText.bookVisit),
      ),
      body: InfiniteList<Appointment>(
        reloadKey: (_timing, _dates, version),
        load: _load,
        header: Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 16),
          child: Column(
            children: [
              EnumFilterChips(
                enumName: 'VisitTiming',
                values: VisitTiming.filters,
                selected: _timing,
                onSelected: (t) => setState(() => _timing = t),
              ),
              const SizedBox(height: 8),
              DateRangeChip(range: _dates, onChanged: (r) => setState(() => _dates = r)),
            ],
          ),
        ),
        empty: EmptyState(
          icon: _timing == VisitTiming.past || _timing == VisitTiming.missed
              ? Icons.history_rounded
              : Icons.event_available_rounded,
          title: switch (_timing) {
            VisitTiming.coming => VisitText.noUpcomingVisits,
            VisitTiming.today => VisitText.noVisitsToday,
            VisitTiming.past => VisitText.noPastVisitsYet,
            VisitTiming.missed => VisitText.noMissedVisits,
            _ => VisitText.noVisitsYet,
          },
          message: _timing == null || _timing == VisitTiming.coming ? VisitText.noVisitsHint : null,
        ),
        itemBuilder: (context, visit, replace) => VisitCard(visit: visit, onChanged: replace),
      ),
    );
  }
}
