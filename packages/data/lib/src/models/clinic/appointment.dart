import 'package:freezed_annotation/freezed_annotation.dart';

import '../../enums/clinic/appointment_status.dart';
import '../../enums/clinic/appointment_type.dart';
import '../../enums/clinic/visit_timing.dart';
import '../shared/refs.dart';

part 'appointment.freezed.dart';
part 'appointment.g.dart';

part 'appointment_slot.dart';

/// Mirror of AppointmentResource (the fields the apps use).
@freezed
abstract class Appointment with _$Appointment {
  const factory Appointment({
    required String id,
    required String code,
    required String patientId,

    /// Sent to staff; the portal leaves it out (it is the patient themself).
    PatientRef? patient,
    required String providerId,
    PersonRef? provider,
    @JsonKey(unknownEnumValue: AppointmentType.unknown) required AppointmentType type,
    String? treatmentId,
    int? sessionNumber,
    required String scheduledDate,
    required String startTime,
    required String endTime,
    NamedRef? room,
    ServiceRef? billableService,
    @JsonKey(unknownEnumValue: AppointmentStatus.unknown) required AppointmentStatus status,

    /// Statuses the booking may move to next (drives the staff action buttons; the server re-checks).
    @JsonKey(unknownEnumValue: AppointmentStatus.unknown) @Default([]) List<AppointmentStatus> allowedTransitions,

    /// Coming, today, past or missed (worked out by the server from the date and the status).
    @JsonKey(unknownEnumValue: VisitTiming.unknown) @Default(VisitTiming.unknown) VisitTiming timing,
    String? reason,
    String? cancellationReason,
    DateTime? checkedInAt,
    DateTime? startedAt,

    /// Check-in opens at this moment: an hour before the start, on the visit's day (null: no limit known).
    DateTime? checkInOpensAt,

    /// The patient may still cancel / reschedule in the app (3 days or more before); closer, reception does it.
    @Default(true) bool patientCanChange,
    required int version,
  }) = _Appointment;

  const Appointment._();

  factory Appointment.fromJson(Map<String, dynamic> json) => _$AppointmentFromJson(json);

  String get doctorName => provider?.fullName ?? 'Your doctor';

  String get patientName => patient?.fullName ?? 'Patient';

  bool canMoveTo(AppointmentStatus next) => allowedTransitions.contains(next);

  /// Whether the desk may check the patient in now (the server refuses earlier check-ins).
  bool checkInOpen(DateTime now) => checkInOpensAt == null || !now.isBefore(checkInOpensAt!);
}
