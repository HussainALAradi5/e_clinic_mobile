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
