import 'package:e_clinic_core/core.dart';

import '../../models/clinic/sick_leave.dart';

/// Sick leave certificates: a patient's own (the server returns only theirs).
class SickLeaveRepository {
  const SickLeaveRepository(this._api);

  final ApiClient _api;

  Future<Paged<SickLeave>> list(ListQuery query) => _api.list('sick-leaves', query, SickLeave.fromJson);
}
