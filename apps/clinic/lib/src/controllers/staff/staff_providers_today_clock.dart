part of 'staff_providers.dart';

/// The signed-in staff member's attendance today and their shift.
class TodayClock extends AsyncNotifier<TodayAttendance> {
  @override
  Future<TodayAttendance> build() => ref.watch(attendanceRepositoryProvider).today();

  /// Puts a fresh check-in / check-out on screen without another request.
  void replace(Attendance row) => state = AsyncData((state.value ?? const TodayAttendance()).copyWith(attendance: row));
}
