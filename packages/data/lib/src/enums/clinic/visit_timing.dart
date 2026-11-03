import 'package:json_annotation/json_annotation.dart';

/// Mirror of App\Enums\Appointments\VisitTiming — where a booking sits in time (a no-show is missed). Worked out by
/// the server from the date and the status.
@JsonEnum(fieldRename: FieldRename.snake)
enum VisitTiming {
  coming,
  today,
  past,
  missed,

  /// A value this app version does not know yet.
  unknown;

  /// The ones offered as filters (not [unknown]).
  static const filters = [coming, today, past, missed];
}
