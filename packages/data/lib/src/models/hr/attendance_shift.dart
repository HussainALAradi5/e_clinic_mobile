part of 'attendance.dart';

/// The working hours of the signed-in staff member (`HH:mm`): late after [start]. When they are on a shift, its
/// [code], [name] and [type] (`fixed` / `flexible` — flexible: [start] is the latest time to arrive).
@freezed
abstract class Shift with _$Shift {
  const factory Shift({String? start, String? end, String? code, String? name, String? type}) = _Shift;

  const Shift._();

  bool get flexible => type == 'flexible';

  /// "Morning (SFT-000004) · 08:00 – 16:00", "Office flexi (SFT-000006) · in by 10:00", or just the hours.
  String? get label {
    if (start == null) return null;
    final hours = flexible ? 'in by $start' : '$start – ${end ?? ''}';
    return name == null ? hours : '$name ($code) · $hours';
  }

  factory Shift.fromJson(Map<String, dynamic> json) => _$ShiftFromJson(json);
}
