import 'package:e_clinic_core/core.dart';
import '../../models/clinic/doctor.dart';

/// Doctors & Specialties (patients see public profiles).
class DoctorRepository {
  const DoctorRepository(this._api);

  final ApiClient _api;

  Future<Paged<Doctor>> list(ListQuery query) => _api.list('doctors', query, Doctor.fromJson);

  Future<Paged<Specialty>> specialties(ListQuery query) => _api.list('doctors/specialties', query, Specialty.fromJson);
}
