/// Wording of the patient's sick leaves.
abstract final class SickLeaveText {
  static const noSickLeaves = 'No sick leaves';
  static const noSickLeavesHint = 'Certificates your doctor gives you show here, with a code your employer can check.';
  static const doctor = 'Doctor';
  static const showTheCode = 'Show the code';

  static String issued(String when) => 'Issued $when';
  static String cancelledByDoctor(String reason) => 'Cancelled by the doctor: $reason';
}
