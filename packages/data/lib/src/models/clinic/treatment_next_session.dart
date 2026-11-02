part of 'treatment.dart';

@freezed
abstract class NextSession with _$NextSession {
  const factory NextSession({required String id, required String scheduledDate, required String startTime}) =
      _NextSession;

  factory NextSession.fromJson(Map<String, dynamic> json) => _$NextSessionFromJson(json);
}
