part of 'treatment.dart';

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
