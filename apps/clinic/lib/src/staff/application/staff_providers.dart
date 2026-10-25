import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_features/features.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bumped after a check-in, start, complete or no-show, so the schedule, sessions and open bookings reload.
class ScheduleVersion extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

final scheduleVersionProvider = NotifierProvider<ScheduleVersion, int>(ScheduleVersion.new);

/// Bumped after a decision, so the approvals list and the tab badge reload.
class ApprovalsVersion extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

final approvalsVersionProvider = NotifierProvider<ApprovalsVersion, int>(ApprovalsVersion.new);

/// Where a booking is in the visit: one chip each on the Today page.
enum VisitStage {
  all('All', []),
  expected('Expected', [AppointmentStatus.pending, AppointmentStatus.confirmed]),
  waiting('Waiting', [AppointmentStatus.checkedIn]),
  withProvider('With doctor', [AppointmentStatus.inProgress]),
  done('Done', [AppointmentStatus.completed, AppointmentStatus.noShow]);

  const VisitStage(this.label, this.statuses);

  final String label;
  final List<AppointmentStatus> statuses;

  bool includes(Appointment visit) => this == all || statuses.contains(visit.status);
}

/// Cancelled and moved bookings never show on a day's schedule.
const _offSchedule = [AppointmentStatus.cancelled, AppointmentStatus.rescheduled];

/// Only my own bookings. Starts on for people who treat patients; front desk staff start with the whole clinic.
/// (Accounts that can only read their own bookings get just those from the server either way.)
class OnlyMine extends Notifier<bool> {
  @override
  bool build() => ref.watch(accessProvider).can('appointments.treat');

  void set(bool value) => state = value;
}

final onlyMineProvider = NotifierProvider<OnlyMine, bool>(OnlyMine.new);

/// Can this user see bookings at all (pharmacists, accountants … cannot).
final canSeeScheduleProvider = Provider<bool>(
  (ref) => ref.watch(accessProvider).can('appointments.read_all | appointments.read_own'),
);

/// Every page of a list (a day's bookings rarely pass one page of 100; five pages cap a runaway loop).
Future<List<T>> _allPages<T>(Future<Paged<T>> Function(int page) load) async {
  final items = <T>[];
  for (var page = 1; page <= 5; page++) {
    final result = await load(page);
    items.addAll(result.items);
    if (!result.hasMore) break;
  }
  return items;
}

/// Today's bookings in time order — visits and treatment sessions together.
final todayScheduleProvider = FutureProvider.autoDispose<List<Appointment>>((ref) {
  ref.watch(scheduleVersionProvider);
  final mine = ref.watch(onlyMineProvider);
  final me = ref.watch(currentUserProvider)?.id;
  final repository = ref.watch(appointmentRepositoryProvider);
  final filter = AllOf([
    Where.eq('scheduledDate', ClinicClock.today()),
    const Where.noneOf('status', _offSchedule),
    // A staff account and its employee record share one id, so the provider is "me".
    if (mine && me != null) Where.eq('providerId', me),
  ]);
  return _allPages(
    (page) => repository.list(
      ListQuery(page: page, perPage: ListQuery.maxPerPage, sort: const ['startTime'], filter: filter),
    ),
  );
});

/// The day shown on the Sessions page (`YYYY-MM-DD`).
class SessionsDay extends Notifier<String> {
  @override
  String build() => ClinicClock.today();

  void set(String day) => state = day;
}

final sessionsDayProvider = NotifierProvider<SessionsDay, String>(SessionsDay.new);

/// My treatment sessions on the chosen day.
final sessionsProvider = FutureProvider.autoDispose<List<Appointment>>((ref) {
  ref.watch(scheduleVersionProvider);
  final day = ref.watch(sessionsDayProvider);
  final me = ref.watch(currentUserProvider)?.id;
  final repository = ref.watch(appointmentRepositoryProvider);
  final filter = AllOf([
    Where.eq('scheduledDate', day),
    const Where.eq('type', AppointmentType.treatmentSession),
    const Where.noneOf('status', _offSchedule),
    if (me != null) Where.eq('providerId', me),
  ]);
  return _allPages(
    (page) => repository.list(
      ListQuery(page: page, perPage: ListQuery.maxPerPage, sort: const ['startTime'], filter: filter),
    ),
  );
});

final appointmentProvider = FutureProvider.autoDispose.family<Appointment, String>((ref, id) {
  ref.watch(scheduleVersionProvider);
  return ref.watch(appointmentRepositoryProvider).get(id);
});

/// Today's bookings of a scanned patient card (searched by the patient's file code).
final patientTodayProvider = FutureProvider.autoDispose.family<List<Appointment>, String>((ref, code) async {
  ref.watch(scheduleVersionProvider);
  final page = await ref
      .watch(appointmentRepositoryProvider)
      .list(
        ListQuery(
          perPage: 20,
          sort: const ['startTime'],
          search: code,
          filter: AllOf([Where.eq('scheduledDate', ClinicClock.today()), const Where.noneOf('status', _offSchedule)]),
        ),
      );
  return page.items;
});

/// The signed-in staff member's attendance today and their shift.
class TodayClock extends AsyncNotifier<TodayAttendance> {
  @override
  Future<TodayAttendance> build() => ref.watch(attendanceRepositoryProvider).today();

  /// Puts a fresh check-in / check-out on screen without another request.
  void replace(Attendance row) => state = AsyncData((state.value ?? const TodayAttendance()).copyWith(attendance: row));
}

final todayClockProvider = AsyncNotifierProvider.autoDispose<TodayClock, TodayAttendance>(TodayClock.new);

/// Everything waiting for this user's decision. Each list is loaded only with the matching right; own requests are
/// left out (the server refuses self-approval anyway).
typedef Approvals = ({
  List<Refund> refunds,
  List<Expense> expenses,
  List<LeaveRequest> leaves,
  List<Attendance> overtime,
});

final approvalsProvider = FutureProvider.autoDispose<Approvals>((ref) async {
  ref.watch(approvalsVersionProvider);
  final access = ref.watch(accessProvider);
  final me = ref.watch(currentUserProvider)?.id;
  const pending = ListQuery(perPage: 50, filter: AllOf([Where.eq('status', 'pending')]));

  Future<List<T>> load<T>(String right, Future<Paged<T>> Function() list) async =>
      access.can(right) ? (await list()).items : <T>[];

  final (refunds, expenses, leaves, overtime) = await (
    load<Refund>('refunds.write & refunds.approve', () => ref.read(refundRepositoryProvider).list(pending)),
    load<Expense>('expenses.write & expenses.approve', () => ref.read(expenseRepositoryProvider).list(pending)),
    load<LeaveRequest>('leaves.write & leaves.approve', () => ref.read(leaveRepositoryProvider).list(pending)),
    load<Attendance>(
      'attendance.write & attendance.approve_overtime',
      () => ref
          .read(attendanceRepositoryProvider)
          .list(
            const ListQuery(
              perPage: 50,
              sort: ['-date'],
              filter: AllOf([Where('overtimeMinutes', 'gt', 0), Where.eq('overtimeApproved', false)]),
            ),
          ),
    ),
  ).wait;
  return (
    refunds: refunds.where((r) => r.requestedBy?.id != me).toList(),
    expenses: expenses.where((e) => e.submittedBy?.id != me).toList(),
    leaves: leaves.where((l) => l.employeeId != me).toList(),
    overtime: overtime.where((a) => a.employeeId != me).toList(),
  );
});

/// The number on the Approvals tab.
final approvalsCountProvider = FutureProvider.autoDispose<int>((ref) async {
  if (!ref
      .watch(accessProvider)
      .can('refunds.approve | expenses.approve | leaves.approve | attendance.approve_overtime')) {
    return 0;
  }
  final a = await ref.watch(approvalsProvider.future);
  return a.refunds.length + a.expenses.length + a.leaves.length + a.overtime.length;
});
