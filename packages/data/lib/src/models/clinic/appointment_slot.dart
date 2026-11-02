part of 'appointment.dart';

/// A free time (GET /portal/slots).
@freezed
abstract class Slot with _$Slot {
  const factory Slot({required String startTime, required String endTime}) = _Slot;

  factory Slot.fromJson(Map<String, dynamic> json) => _$SlotFromJson(json);
}
