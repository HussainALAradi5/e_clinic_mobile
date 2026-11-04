import 'package:e_clinic_core/core.dart';

import '../../models/billing/appointment_fee.dart';

/// Fees for missed and late-cancelled visits (patients: their own). Charging and waiving happen on the server.
class AppointmentFeeRepository {
  const AppointmentFeeRepository(this._api);

  final ApiClient _api;

  Future<Paged<AppointmentFee>> list(ListQuery query) =>
      _api.list('billing/appointment-fees', query, AppointmentFee.fromJson);
}
