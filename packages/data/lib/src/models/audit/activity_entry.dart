import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity_entry.freezed.dart';
part 'activity_entry.g.dart';

part 'activity_entry_activity_change.dart';

/// One row of a record's event log (GET /activity/{entity}/{id}), newest first. Read-only.
@freezed
abstract class ActivityEntry with _$ActivityEntry {
  const factory ActivityEntry({
    required String id,

    /// An `AuditAction` value.
    required String action,
    required String actionLabel,
    required String entity,
    @Default([]) List<ActivityChange> changes,

    /// Null when no person made the change.
    String? changedBy,
    required DateTime createdAt,
  }) = _ActivityEntry;

  factory ActivityEntry.fromJson(Map<String, dynamic> json) => _$ActivityEntryFromJson(json);
}
