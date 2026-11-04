import 'package:e_clinic_core/core.dart';

import '../../models/hr/doctor_earning.dart';

/// My commission as a doctor (the server returns only my own row).
class EarningRepository {
  const EarningRepository(this._api);

  final ApiClient _api;

  Future<DoctorEarning?> mine(int year, int month) => _api.get(
    'hr/doctor-earnings',
    (data) => (data as List<dynamic>).map((r) => DoctorEarning.fromJson(r as Map<String, dynamic>)).firstOrNull,
    query: {'year': year, 'month': month},
  );
}
