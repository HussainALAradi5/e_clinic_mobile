import 'package:e_clinic_core/core.dart';

import '../../models/hr/staff_request.dart';

/// Staff requests — late excuses and overtime: staff ask about their days, HR approves (reason optional) or rejects
/// (reason required). HR's switches decide which kinds can be asked.
class StaffRequestRepository {
  const StaffRequestRepository(this._api);

  final ApiClient _api;

  /// Own requests, or everyone's for HR.
  Future<Paged<StaffRequest>> list(ListQuery query) => _api.list('hr/requests', query, StaffRequest.fromJson);

  /// My recent days that can still be asked about (only kinds HR has switched on).
  Future<List<AskableDay>> askable() => _api.get('hr/requests/askable', listOf(AskableDay.fromJson));

  Future<StaffRequest> create({required String type, required String attendanceId, String? reason}) => _api.post(
    'hr/requests',
    objectOf(StaffRequest.fromJson),
    body: {'type': type, 'attendance_id': attendanceId, 'reason': ?reason},
  );

  Future<StaffRequest> approve(String id, {String? reason}) =>
      _api.patch('hr/requests/$id/approve', objectOf(StaffRequest.fromJson), body: {'reason': ?reason});

  Future<StaffRequest> reject(String id, String reason) =>
      _api.patch('hr/requests/$id/reject', objectOf(StaffRequest.fromJson), body: {'reason': reason});

  /// The requester withdraws a pending request; the day can be asked about again.
  Future<StaffRequest> cancel(String id) => _api.patch('hr/requests/$id/cancel', objectOf(StaffRequest.fromJson));

  /// Overtime requests are on: overtime is then approved only through requests (HR settings, needs `settings.read_all`).
  Future<bool> overtimeByRequest() async {
    final settings = await _api.get(
      'hr/settings',
      listOf((json) => (key: json['key'] as String?, on: json['is_enabled'] == true)),
      query: {'per_page': 50},
    );
    return settings.any((s) => s.key == 'overtime' && s.on);
  }
}
