part of 'staff_request.dart';

/// Snapshot kept on the request: the minutes and, for overtime, the rate per hour and amount; for a late arrival,
/// what it would cost if not excused.
@freezed
abstract class StaffRequestDetails with _$StaffRequestDetails {
  const factory StaffRequestDetails({@Default(0) int minutes, String? rate, Money? amount}) = _StaffRequestDetails;

  factory StaffRequestDetails.fromJson(Map<String, dynamic> json) => _$StaffRequestDetailsFromJson(json);
}
