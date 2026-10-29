import 'package:json_annotation/json_annotation.dart';

/// Mirror of App\Enums\Appointments\AppointmentStatus.
@JsonEnum(fieldRename: FieldRename.snake)
enum AppointmentStatus {
  pending,
  confirmed,
  checkedIn,
  inProgress,
  completed,
  cancelled,
  noShow,
  rescheduled,

  /// A value this app version does not know yet.
  unknown;

  /// Still ahead of the patient (shown under *Upcoming*).
  static const upcoming = [pending, confirmed, checkedIn];

  /// The patient may still cancel online (the server also enforces the 2-hour window).
  bool get cancellable => this == pending || this == confirmed;
}
