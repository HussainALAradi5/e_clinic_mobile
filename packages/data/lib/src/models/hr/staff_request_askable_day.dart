part of 'staff_request.dart';

/// GET hr/requests/askable — a recent day of mine and the kinds of request it still allows.
@freezed
abstract class AskableDay with _$AskableDay {
  const factory AskableDay({required Attendance attendance, @Default([]) List<String> types}) = _AskableDay;

  factory AskableDay.fromJson(Map<String, dynamic> json) => _$AskableDayFromJson(json);
}
