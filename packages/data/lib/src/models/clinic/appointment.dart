import 'package:freezed_annotation/freezed_annotation.dart';

import '../../enums/clinic/appointment_status.dart';
import '../../enums/clinic/appointment_type.dart';
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
    String? reason,
    String? cancellationReason,
    DateTime? checkedInAt,
    DateTime? startedAt,
    required int version,
  }) = _Appointment;

  const Appointment._();

  factory Appointment.fromJson(Map<String, dynamic> json) => _$AppointmentFromJson(json);

  String get doctorName => provider?.fullName ?? 'Your doctor';

  String get patientName => patient?.fullName ?? 'Patient';

  bool canMoveTo(AppointmentStatus next) => allowedTransitions.contains(next);
}
