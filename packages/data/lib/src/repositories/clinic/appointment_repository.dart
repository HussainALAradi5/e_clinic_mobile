import 'package:e_clinic_core/core.dart';

import '../../enums/clinic/appointment_source.dart';
import '../../enums/clinic/appointment_type.dart';
import '../../models/clinic/appointment.dart';
import '../../models/clinic/booking_provider.dart';

/// Appointments & Treatment Sessions (patients receive only their own).
class AppointmentRepository {
  const AppointmentRepository(this._api);

  final ApiClient _api;

  Future<Paged<Appointment>> list(ListQuery query) => _api.list('appointments', query, Appointment.fromJson);

  Future<Appointment> get(String id) => _api.get('appointments/$id', objectOf(Appointment.fromJson));

  /// Every booking from [from] to [to] (`YYYY-MM-DD`, at most 31 days), visits and sessions together.
  Future<List<Appointment>> calendar({required String from, required String to, String? providerId}) => _api.get(
    'appointments/calendar',
    listOf(Appointment.fromJson),
    query: {'from': from, 'to': to, 'provider_id': providerId},
  );

  /// Who can be booked for [type] (doctors; medical staff too for treatment sessions).
  Future<List<BookingProvider>> providers(AppointmentType type) =>
      _api.get('appointments/providers', listOf(BookingProvider.fromJson), query: {'type': wireValue(type)});

  /// Free times of [providerId] on [date] for [type].
  Future<List<Slot>> availableSlots({
    required String providerId,
    required String date,
    required AppointmentType type,
  }) => _api.get(
    'appointments/available-slots',
    listOf(Slot.fromJson),
    query: {'provider_id': providerId, 'date': date, 'type': wireValue(type)},
  );

  /// Books a visit at the desk; staff bookings start confirmed. Keep [idempotencyKey] for retries of one attempt.
  Future<Appointment> book({
    required String patientId,
    required String providerId,
    required AppointmentType type,
    required String date,
    required String startTime,
    required AppointmentSource source,
    String? reason,
    required String idempotencyKey,
  }) => _api.post(
    'appointments',
    objectOf(Appointment.fromJson),
    idempotencyKey: idempotencyKey,
    body: {
      'patient_id': patientId,
      'provider_id': providerId,
      'type': wireValue(type),
      'scheduled_date': date,
      'start_time': startTime,
      'source': wireValue(source),
      'reason': ?reason,
    },
  );

  Future<Appointment> confirm(String id) => _transition(id, 'confirm');

  Future<Appointment> checkIn(String id) => _transition(id, 'check-in');

  Future<Appointment> start(String id) => _transition(id, 'start');

  Future<Appointment> noShow(String id) => _transition(id, 'no-show');

  /// Charges the visit to the patient's invoice; [followUpInDays] suggests the next visit.
  Future<Appointment> complete(String id, {int? followUpInDays}) => _api.patch(
    'appointments/$id/complete',
    objectOf(Appointment.fromJson),
    body: {'follow_up_in_days': ?followUpInDays},
  );

  Future<Appointment> _transition(String id, String action) =>
      _api.patch('appointments/$id/$action', objectOf(Appointment.fromJson));
}
