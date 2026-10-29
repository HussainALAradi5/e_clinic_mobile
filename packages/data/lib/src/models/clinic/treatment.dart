import 'package:freezed_annotation/freezed_annotation.dart';

import '../../enums/clinic/appointment_status.dart';
import '../../enums/shared/generic_status.dart';
import '../shared/refs.dart';

part 'treatment.freezed.dart';
part 'treatment.g.dart';

@freezed
abstract class NextSession with _$NextSession {
  const factory NextSession({required String id, required String scheduledDate, required String startTime}) =
      _NextSession;

  factory NextSession.fromJson(Map<String, dynamic> json) => _$NextSessionFromJson(json);
}

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

/// How a treatment plan is going — drives the colour of its progress bar.
enum ProgressHealth {
  notStarted('Not started'),
  onTrack('On track'),
  slipping('Missing sessions'),
  atRisk('At risk'),
  done('Completed'),
  stopped('Stopped');

  const ProgressHealth(this.label);

  final String label;
}

/// Mirror of TreatmentResource.
@freezed
abstract class Treatment with _$Treatment {
  const factory Treatment({
    required String id,
    required String code,
    required String type,
    required String title,
    PersonRef? doctor,
    @JsonKey(unknownEnumValue: GenericStatus.unknown) required GenericStatus status,
    required int plannedSessions,
    String? startDate,
    String? endDate,
    TreatmentProgress? progress,
  }) = _Treatment;

  const Treatment._();

  factory Treatment.fromJson(Map<String, dynamic> json) => _$TreatmentFromJson(json);

  int get attended => progress?.attendedSessions ?? 0;

  /// How the plan is going (same rules as the web): done, stopped, at risk (2 missed in a row or under 60 %
  /// attended), missing sessions (any miss or under 85 %), not started, on track.
  ProgressHealth get health {
    final p = progress;
    if (status == GenericStatus.cancelled) return ProgressHealth.stopped;
    final allAttended = plannedSessions > 0 && attended >= plannedSessions;
    if (status == GenericStatus.completed || allAttended) return ProgressHealth.done;
    if (p == null) return ProgressHealth.notStarted;
    final rate = p.attendanceRate;
    if (p.consecutiveAbsences >= 2 || (rate != null && rate < 60)) return ProgressHealth.atRisk;
    if (p.absentSessions > 0 || (rate != null && rate < 85)) return ProgressHealth.slipping;
    return attended == 0 ? ProgressHealth.notStarted : ProgressHealth.onTrack;
  }

  /// 0.0 – 1.0 of the planned sessions attended.
  double get completion => plannedSessions == 0 ? 0 : (attended / plannedSessions).clamp(0, 1).toDouble();
}

/// One session of a plan (GET /treatments/{id}/sessions).
@freezed
abstract class TreatmentSession with _$TreatmentSession {
  const factory TreatmentSession({
    required String id,
    required int sessionNumber,
    required String scheduledDate,
    required String startTime,
    PersonRef? provider,
    NamedRef? room,
    @JsonKey(unknownEnumValue: AppointmentStatus.unknown) required AppointmentStatus status,
    @Default(false) bool isAttended,
  }) = _TreatmentSession;

  factory TreatmentSession.fromJson(Map<String, dynamic> json) => _$TreatmentSessionFromJson(json);
}
