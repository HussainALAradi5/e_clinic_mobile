/// Text of the patient's insurance split on an invoice.
abstract final class CoverageText {
  static String covers(String insurer, String percent) =>
      '$insurer covers ${double.tryParse(percent)?.round() ?? percent} % of the covered services';
  static const insurerPart = 'Claimed from your insurer';
  static const myPart = 'Your part';
}
