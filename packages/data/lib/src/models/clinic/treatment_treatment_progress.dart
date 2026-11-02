part of 'treatment.dart';

/// Attendance and progress computed by the server from the session appointments.
@freezed
abstract class TreatmentProgress with _$TreatmentProgress {
  const factory TreatmentProgress({
    @Default(0) int attendedSessions,
    @Default(0) int absentSessions,
    @Default(0) int upcomingSessions,
    @Default(0) int remainingSessions,
    @Default(0) int consecutiveAbsences,
    double? attendanceRate,
    NextSession? nextSession,
  }) = _TreatmentProgress;

  factory TreatmentProgress.fromJson(Map<String, dynamic> json) => _$TreatmentProgressFromJson(json);
}
