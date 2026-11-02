import 'package:e_clinic_data/data.dart';

import 'formatters.dart';

/// How much of each prescription line to hand over now, by prescription item id.
typedef DispenseQuantities = Map<String, double>;

/// Everything still owed, the starting point of the dispense screen.
DispenseQuantities owedQuantities(Prescription prescription) => {
  for (final item in prescription.items)
    if (item.outstanding > 0) item.id: item.outstanding,
};

/// The lines to send: only those with something to hand over.
List<DispenseLine> dispenseLines(Prescription prescription, DispenseQuantities quantities) => [
  for (final item in prescription.items)
    if ((quantities[item.id] ?? 0) > 0)
      (medicationId: item.medication.id, prescriptionItemId: item.id, quantity: formatQuantity(quantities[item.id]!)),
];

/// A controlled drug is being handed over, so a second member of staff must witness it.
bool needsWitness(Prescription prescription, DispenseQuantities quantities) =>
    prescription.items.any((item) => item.medication.isControlled && (quantities[item.id] ?? 0) > 0);

/// The prescription line a scanned pack belongs to: its barcode (GTIN) or the clinic's medication code, ignoring
/// leading zeros a scanner may add to an EAN. Null when the pack is not on this prescription.
PrescriptionItem? itemForBarcode(Prescription prescription, String code) {
  String plain(String value) => value.trim().replaceFirst(RegExp('^0+'), '').toUpperCase();
  final scanned = plain(code);
  if (scanned.isEmpty) return null;
  return prescription.items
      .where(
        (item) =>
            (item.medication.gtin != null && plain(item.medication.gtin!) == scanned) ||
            (item.medication.code != null && plain(item.medication.code!) == scanned),
      )
      .firstOrNull;
}
