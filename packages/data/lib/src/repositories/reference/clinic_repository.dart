import 'package:e_clinic_core/core.dart';

/// The clinic's public profile, as far as the app needs it.
class ClinicRepository {
  const ClinicRepository(this._api);

  final ApiClient _api;

  /// The clinic has switched online payments on (admin settings): the portal shows Pay online.
  Future<bool> onlinePaymentsEnabled() =>
      _api.get('public/clinic-profile', (data) => (data as Map<String, dynamic>)['online_payments_enabled'] == true);
}
