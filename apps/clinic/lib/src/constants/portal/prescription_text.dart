/// Wording of the patient's prescriptions.
abstract final class PrescriptionText {
  static const noPrescriptions = 'No prescriptions';
  static const noPrescriptionsHint = 'Medicines your doctor prescribes show here, with the code for the pharmacy.';
  static const pharmacyCode = 'Pharmacy code';

  static String validUntil(String date) => 'Valid until $date';

  static const collected = 'Collected';
}
