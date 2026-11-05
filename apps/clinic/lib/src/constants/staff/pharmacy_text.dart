/// Wording of the pharmacy queue and dispensing.
abstract final class PharmacyText {
  static const dispensedMedicines = 'Dispensed medicines';
  static const nothingDispensedYet = 'Nothing dispensed yet';
  static const dispense = 'Dispense';
  static const scanAPack = 'Scan a pack';
  static const notesHint = 'e.g. patient will collect the rest next week';
  static const dispenseWarning = 'Stock goes down and the medicines are added to the invoice.';
  static const pharmacyQueue = 'Pharmacy queue';
  static const queueIsEmpty = 'Queue is empty';
  static const queueEmptyHint = 'Every valid prescription has been handed over.';
  static const cancelWarning = 'The medicines go back to stock and the charge is reversed.';
  static const cancelDispensation = 'Cancel dispensation';
  static const dispensedBy = 'By';
  static const witness = 'Witness';
  static const packScannedAndMatched = 'Pack scanned and matched';
  static const needsWitness = 'Controlled drug — needs a witness';
  static const less = 'Less';
  static const pointAtBarcode = 'Point at the barcode on the pack';
  static const typeIt = 'Type it';
  static const barcodeNumber = 'Barcode number';
  static const barcodeHint = 'e.g. 6291100000000';
  static const controlled = 'Controlled';
  static const witnessLabel = 'Colleague who checks the controlled drug';

  static String packNotPrescribed(String code) => 'This pack ($code) is not on the prescription.';
  static String handOver(int count) => 'Hand over $count medicine${count == 1 ? '' : 's'}?';
  static String batch(String number, String expires) => 'Batch $number · expires $expires';
  static String cancelTitle(String code) => 'Cancel $code?';

  static const medicines = 'Medicines';
  static const notesOptional = 'Notes (optional)';
  static const nothingToHandOver = 'Nothing to hand over';
  static const chooseAWitness = 'Choose a witness';
  static const allHandedOver = 'All handed over';
}
