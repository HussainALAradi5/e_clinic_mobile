import 'package:freezed_annotation/freezed_annotation.dart';

import '../../enums/clinic/appointment_status.dart';
import '../../enums/shared/generic_status.dart';
import '../shared/refs.dart';

part 'treatment.freezed.dart';
part 'treatment.g.dart';

part 'treatment_next_session.dart';
part 'treatment_progress_health.dart';
part 'treatment_treatment_progress.dart';
part 'treatment_treatment_session.dart';

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
