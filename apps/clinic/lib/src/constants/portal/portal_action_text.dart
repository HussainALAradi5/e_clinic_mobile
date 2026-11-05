/// Wording of the portal steps: visit, prescription and sick-leave codes, cancelling a visit.
abstract final class PortalActionText {
  static const checkInCode = 'Check-in code';
  static const checkInHint = 'Show this at the front desk when you arrive. It works only for this visit.';
  static const prescriptionCode = 'Prescription code';
  static String validUntil(String date) => 'Valid until $date';
  static const prescriptionHint = 'Show this at the clinic pharmacy to collect your medicines.';
  static String sickLeave(String code) => 'Sick leave $code';
  static String sickLeaveDays(int days, String from, String to) => '$days ${days == 1 ? 'day' : 'days'}: $from – $to';
  static const sickLeaveHint = 'Your employer or school scans this to check the certificate with the clinic. It shows the dates only.';
  static const cancelTitle = 'Cancel this visit?';
  static String cancelMessage(String day, String time, String doctor, String feeRules) =>
      '$day at $time with $doctor. Online cancellation closes 3 days before the start; after that, call reception. $feeRules';
  static const cancelConfirm = 'Cancel visit';
  static const keepIt = 'Keep it';
  static const cancelReason = 'Why are you cancelling?';
  static const cancelled = 'Your visit is cancelled.';
}
