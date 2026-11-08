part of 'activity_entry.dart';

/// One field an event changed; `old` and `new` are null when the field was empty.
@freezed
abstract class ActivityChange with _$ActivityChange {
  const factory ActivityChange({
    required String field,
    required String label,
    @JsonKey(name: 'old') Object? oldValue,
    @JsonKey(name: 'new') Object? newValue,
  }) = _ActivityChange;

  factory ActivityChange.fromJson(Map<String, dynamic> json) => _$ActivityChangeFromJson(json);
}
