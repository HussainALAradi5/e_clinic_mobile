import 'package:e_clinic_core/core.dart';

import '../../enums/clinic/appointment_type.dart';
import '../../models/clinic/appointment.dart';
import '../../models/clinic/patient.dart';

/// Patient portal — what patients change themselves (`/portal/*`).
class PortalRepository {
  const PortalRepository(this._api);

  final ApiClient _api;

  Future<Patient> profile() => _api.get('portal/profile', objectOf(Patient.fromJson));

  /// Contact details and emergency contact; `version` / `personVersion` lock the patient file and the person.
  Future<Patient> updateProfile({
    required int version,
    required int personVersion,
    required String phone,
    String? email,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? emergencyContactRelation,
  }) => _api.put(
    'portal/profile',
    objectOf(Patient.fromJson),
    body: {
      'version': version,
      'person_version': personVersion,
      'phone': phone,
      'email': ?email,
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_phone': emergencyContactPhone,
      'emergency_contact_relation': emergencyContactRelation,
    },
  );

  /// Free times that can still be booked online (at least two hours ahead).
  Future<List<Slot>> slots({required String doctorId, required String date, required AppointmentType type}) => _api.get(
    'portal/slots',
    listOf(Slot.fromJson),
    query: {'doctor_id': doctorId, 'date': date, 'type': wireValue(type)},
  );

  /// Books for the signed-in patient; starts `pending` until the clinic confirms it.
  Future<Appointment> book({
    required String doctorId,
    required AppointmentType type,
    required String date,
    required String startTime,
    String? reason,
    required String idempotencyKey,
  }) => _api.post(
    'portal/appointments',
    objectOf(Appointment.fromJson),
    idempotencyKey: idempotencyKey,
    body: {
      'doctor_id': doctorId,
      'type': wireValue(type),
      'scheduled_date': date,
      'start_time': startTime,
      'reason': reason,
    },
  );

  Future<Appointment> cancel(String id, String reason) =>
      _api.patch('portal/appointments/$id/cancel', objectOf(Appointment.fromJson), body: {'reason': reason});
}
