import 'package:e_clinic_core/core.dart';

/// The owner's month-end summary (report readers only): the month and the month before, as maps of figures.
class MonthSummaryRepository {
  const MonthSummaryRepository(this._api);

  final ApiClient _api;

  Future<Map<String, dynamic>> month(int year, int month) => _api.get(
    'accounting/month-summary',
    (data) => data as Map<String, dynamic>,
    query: {'year': year, 'month': month},
  );
}
