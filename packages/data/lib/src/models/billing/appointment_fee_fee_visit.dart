part of 'appointment_fee.dart';

/// The missed visit of a fee.
@freezed
abstract class FeeVisit with _$FeeVisit {
  const factory FeeVisit({required String id, required String code, required String scheduledDate, String? startTime}) =
      _FeeVisit;

  factory FeeVisit.fromJson(Map<String, dynamic> json) => _$FeeVisitFromJson(json);
}
