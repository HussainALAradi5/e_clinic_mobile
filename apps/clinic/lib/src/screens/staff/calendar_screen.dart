import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_shell/shell.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/routes/staff_paths.dart';
import '../../constants/staff/appointment_text.dart';
import '../../controllers/staff/calendar_providers.dart';
import '../../controllers/staff/staff_providers.dart';
import '../../widgets/staff/appointments/appointment_card.dart';

/// `/clinic/calendar` — a day of bookings (visits and treatment sessions) by provider, the two weeks ahead in the
/// strip; *Book* for those who may book.
class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  static const _daysShown = 14;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final day = ref.watch(calendarDayProvider);
    final access = ref.watch(accessProvider);
    final mine = ref.watch(onlyMineProvider);
    final today = ClinicClock.today();
    final days = [for (var i = 0; i < _daysShown; i++) ClinicClock.addDays(today, i)];
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppointmentText.calendar),
        actions: [
          if (access.can('appointments.read_all'))
            IconButton(
              tooltip: mine ? AppointmentText.showWholeClinic : AppointmentText.showOnlyMine,
              isSelected: mine,
              icon: const Icon(Icons.groups_outlined),
              selectedIcon: const Icon(Icons.person_rounded),
              onPressed: () => ref.read(onlyMineProvider.notifier).set(!mine),
            ),
        ],
      ),
      floatingActionButton: access.can('appointments.create')
          ? FloatingActionButton.extended(
              onPressed: () => context.push(StaffPaths.book),
              icon: const Icon(Icons.add_rounded),
              label: const Text(AppointmentText.book),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(calendarProvider);
          await ref.read(calendarProvider.future);
        },
        child: ListView(
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            const SizedBox(height: 4),
            DayStrip(days: days, selected: day, onSelected: ref.read(calendarDayProvider.notifier).set),
            ref
                .watch(calendarProvider)
                .when(
                  loading: () =>
                      const Padding(padding: EdgeInsets.only(top: 16), child: SkeletonList(count: 3, height: 140)),
                  error: (error, _) => ErrorState(error: error, onRetry: () => ref.invalidate(calendarProvider)),
                  data: (columns) => columns.isEmpty
                      ? EmptyState(
                          icon: Icons.event_available_outlined,
                          title: AppointmentText.nothingBooked,
                          message: '${ClinicClock.relativeDay(day)} has no bookings${mine ? ' with you' : ''}.',
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (final column in columns) ...[
                              SectionHeader(
                                column.name,
                                trailing: Text(
                                  '${column.bookings.length}',
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                              ),
                              for (final booking in column.bookings)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                                  child: AppointmentCard(visit: booking, showProvider: false),
                                ),
                            ],
                          ],
                        ),
                ),
          ],
        ),
      ),
    );
  }
}
