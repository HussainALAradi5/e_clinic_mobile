import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bumped after a dispense or cancel, so the queue and the dispensed list reload.
class PharmacyVersion extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

final pharmacyVersionProvider = NotifierProvider<PharmacyVersion, int>(PharmacyVersion.new);

/// A page of dispensed medicines (newest first).
ListQuery dispensationsQuery(int page) => ListQuery(page: page, perPage: 25, sort: const ['-dispensedAt']);

/// One prescription with what each line still needs.
final prescriptionProvider = FutureProvider.autoDispose.family<Prescription, String>((ref, id) {
  ref.watch(pharmacyVersionProvider);
  return ref.watch(prescriptionRepositoryProvider).get(id);
});

/// Colleagues who may witness a controlled drug.
final witnessesProvider = FutureProvider.autoDispose<List<PersonRef>>(
  (ref) => ref.watch(dispensationRepositoryProvider).witnesses(),
);
