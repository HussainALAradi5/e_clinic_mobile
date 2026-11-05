/// Wording of the clinical-order steps and work-list chips.
abstract final class OrderActionText {
  static const start = 'Start';
  static const writeResult = 'Write result';
  static const cancelOrder = 'Cancel order';
  static String cancelTitle(String code) => 'Cancel $code?';
  static const keep = 'Keep';
  static String started(String code) => '$code started.';
  static String resultSaved(String? patient) => 'Result saved. ${patient ?? 'The patient'} can see it now.';
  static String cancelled(String code) => '$code cancelled.';
  static const all = 'All';
  static const imaging = 'Imaging';
  static const lab = 'Lab';
  static const ecg = 'ECG';
  static const referrals = 'Referrals';
}
