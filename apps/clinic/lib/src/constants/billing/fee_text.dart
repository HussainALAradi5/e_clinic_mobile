/// Text of the patient's visit fees and the fee rules shown when cancelling.
abstract final class FeeText {
  static const title = 'Visit fees';
  static const rules =
      'A missed visit, or a cancellation within 24 hours of it, is charged on your invoice. '
      'Call reception if something urgent happened — they can review it.';
  static const waived = 'Waived';
  static String visit(String code, String day) => '$code · $day';
  static const types = {'no_show': 'Missed appointment', 'late_cancel': 'Late cancellation'};
}
