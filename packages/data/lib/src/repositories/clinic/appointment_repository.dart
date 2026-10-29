import 'package:e_clinic_core/core.dart';
import '../../models/clinic/appointment.dart';

/// Appointments & Treatment Sessions (patients receive only their own).
class AppointmentRepository {
  const AppointmentRepository(this._api);

  final ApiClient _api;

  Future<Paged<Appointment>> list(ListQuery query) => _api.list('appointments', query, Appointment.fromJson);

  Future<Appointment> get(String id) => _api.get('appointments/$id', objectOf(Appointment.fromJson));

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
