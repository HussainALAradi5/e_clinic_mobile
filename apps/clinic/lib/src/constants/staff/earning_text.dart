/// Text of a doctor's own earnings card.
abstract final class EarningText {
  static const title = 'My earnings this month';
  static const hint = 'Commission so far; the final amount is on your payslip.';
  static String terms(String type, String rate) => switch (type) {
    'percent' => '${double.tryParse(rate)?.toStringAsFixed(0) ?? rate} % of your revenue',
    'per_visit' => '$rate per visit',
    _ => '',
  };
  static String visits(int n) => n == 1 ? '1 visit' : '$n visits';
}
