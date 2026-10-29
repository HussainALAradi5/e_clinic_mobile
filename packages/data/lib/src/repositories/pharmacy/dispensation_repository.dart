import 'package:e_clinic_core/core.dart';

import '../../models/pharmacy/dispensation.dart';
import '../../models/shared/refs.dart';

/// One medicine to hand over: [quantity] of [medicationId] for a prescription line (batch picked by the server,
/// first expiry first out).
typedef DispenseLine = ({String medicationId, String? prescriptionItemId, String quantity});

/// Dispensing — medicine leaving stock for a patient.
class DispensationRepository {
  const DispensationRepository(this._api);

  final ApiClient _api;

  Future<Paged<Dispensation>> list(ListQuery query) =>
      _api.list('pharmacy/dispensations', query, Dispensation.fromJson);

  Future<Dispensation> get(String id) => _api.get('pharmacy/dispensations/$id', objectOf(Dispensation.fromJson));

  /// Hands medicine over (take-home); adds the lines to the patient's invoice. Controlled drugs need [witnessId].
  Future<Dispensation> dispense({
    required String patientId,
    String? prescriptionId,
    required List<DispenseLine> items,
    String? witnessId,
    String? notes,
    required String idempotencyKey,
  }) => _api.post(
    'pharmacy/dispensations',
    objectOf(Dispensation.fromJson),
    idempotencyKey: idempotencyKey,
    body: {
      'patient_id': patientId,
      'prescription_id': ?prescriptionId,
      'items': [
        for (final line in items)
          {
            'medication_id': line.medicationId,
            'prescription_item_id': ?line.prescriptionItemId,
            'quantity': line.quantity,
          },
      ],
      'witness_id': ?witnessId,
      'notes': ?notes,
    },
  );

  /// Puts the stock back and reverses the charge.
  Future<Dispensation> cancel(String id, String reason) =>
      _api.patch('pharmacy/dispensations/$id/cancel', objectOf(Dispensation.fromJson), body: {'reason': reason});

  /// Colleagues who may witness a controlled drug (`dispense` or `administer`), never the signed-in user.
  Future<List<PersonRef>> witnesses({String right = 'dispense'}) =>
      _api.get('pharmacy/colleagues', listOf(PersonRef.fromJson), query: {'right': right});
}
