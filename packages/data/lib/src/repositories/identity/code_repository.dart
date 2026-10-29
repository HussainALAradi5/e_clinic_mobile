import 'package:e_clinic_core/core.dart';
import '../../models/identity/scan_result.dart';

/// QR codes & barcodes — one endpoint resolves any signed code to its record.
class CodeRepository {
  const CodeRepository(this._api);

  final ApiClient _api;

  /// `purpose`: `identify`, `check_in`, `verify_document` or `sample_label`. A forged or unknown code → 422.
  Future<ScanResult> scan(String payload, {String purpose = 'identify'}) =>
      _api.post('codes/scan', objectOf(ScanResult.fromJson), body: {'payload': payload.trim(), 'purpose': purpose});
}
