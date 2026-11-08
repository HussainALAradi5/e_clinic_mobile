import 'package:e_clinic_core/core.dart';

import '../../enums/audit/activity_entity.dart';
import '../../models/audit/activity_entry.dart';

/// The event log of a record (`activity.read_all`). Read-only.
class ActivityRepository {
  const ActivityRepository(this._api);

  final ApiClient _api;

  /// Newest first; [cursor] is the `next_cursor` of the page before.
  Future<Paged<ActivityEntry>> list(ActivityEntity entity, String id, {required int perPage, String? cursor}) =>
      _api.list(
        'activity/${entity.wire}/$id',
        ListQuery(perPage: perPage),
        ActivityEntry.fromJson,
        extra: {'cursor': cursor},
      );
}
