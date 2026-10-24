import 'package:e_clinic_core/core.dart';

import '../models/appointment.dart';
import '../models/clinical_order.dart';
import '../models/doctor.dart';
import '../models/treatment.dart';

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

/// Doctors & Specialties (patients see public profiles).
class DoctorRepository {
  const DoctorRepository(this._api);

  final ApiClient _api;

  Future<Paged<Doctor>> list(ListQuery query) => _api.list('doctors', query, Doctor.fromJson);

  Future<Paged<Specialty>> specialties(ListQuery query) =>
      _api.list('doctors/specialties', query, Specialty.fromJson);
}

class TreatmentRepository {
  const TreatmentRepository(this._api);

  final ApiClient _api;

  Future<Paged<Treatment>> list(ListQuery query) => _api.list('treatments', query, Treatment.fromJson);

  Future<List<TreatmentSession>> sessions(String id) =>
      _api.get('treatments/$id/sessions', listOf(TreatmentSession.fromJson));
}

/// Clinical Orders — X-ray, imaging, lab and referrals; reports reach patients once completed.
class ClinicalOrderRepository {
  const ClinicalOrderRepository(this._api);

  final ApiClient _api;

  Future<Paged<ClinicalOrder>> list(ListQuery query) =>
      _api.list('clinical-orders', query, ClinicalOrder.fromJson);

  Future<ClinicalOrder> get(String id) => _api.get('clinical-orders/$id', objectOf(ClinicalOrder.fromJson));
}

/// Attachments — files open through short-lived signed links.
class AttachmentRepository {
  const AttachmentRepository(this._api);

  final ApiClient _api;

  Future<SignedLink> downloadLink(String id, {bool inline = true}) => _api.get(
    'attachments/$id/download',
    objectOf(SignedLink.fromJson),
    query: {if (inline) 'inline': 1},
  );
}
