/// Wording of the visit steps and the Today stage chips.
abstract final class VisitActionText {
  static const checkIn = 'Check in';
  static const start = 'Start';
  static const complete = 'Complete';
  static const confirm = 'Confirm';
  static const noShow = 'No show';
  static const noShowTitle = 'Mark as no-show?';
  static String noShowMessage(String who) => '$who. The patient did not come; this cannot be undone.';
  static String who(String patient, String time) => '$patient, $time';
  static String checkedIn(String patient) => '$patient is checked in.';
  static const started = 'Visit started.';
  static const completed = 'Visit completed and charged.';
  static const confirmed = 'Booking confirmed.';
  static const markedNoShow = 'Marked as no-show.';
  static const stageAll = 'All';
  static const stageExpected = 'Expected';
  static const stageWaiting = 'Waiting';
  static const stageWithDoctor = 'With doctor';
  static const stageDone = 'Done';
}
