part of 'staff_request.dart';

/// The day a request is about, as attendance measured it.
@freezed
abstract class StaffRequestDay with _$StaffRequestDay {
  const factory StaffRequestDay({
    required String id,
    required String date,
    DateTime? checkInAt,
    DateTime? checkOutAt,
    @Default(0) int workedMinutes,
  }) = _StaffRequestDay;

  factory StaffRequestDay.fromJson(Map<String, dynamic> json) => _$StaffRequestDayFromJson(json);
}
