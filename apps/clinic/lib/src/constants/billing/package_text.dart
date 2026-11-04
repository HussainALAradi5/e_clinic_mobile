/// Text of the patient's packages.
abstract final class PackageText {
  static const title = 'My packages';
  static String left(int left, int total) => '$left of $total sessions left';
  static String validUntil(String date) => 'Valid until $date';
  static const awaiting = 'Starts once its invoice is paid.';
}
