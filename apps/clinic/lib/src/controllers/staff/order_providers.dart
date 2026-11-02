import 'package:e_clinic_data/data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bumped after a start, complete or cancel, so the work list and the order reload.
class OrdersVersion extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

final ordersVersionProvider = NotifierProvider<OrdersVersion, int>(OrdersVersion.new);

/// Which orders the work list shows (one chip each).
enum OrderKind {
  all('All', []),
  imaging('Imaging', [
    ClinicalOrderType.xray,
    ClinicalOrderType.ultrasound,
    ClinicalOrderType.ct,
    ClinicalOrderType.mri,
  ]),
  lab('Lab', [ClinicalOrderType.labTest]),
  ecg('ECG', [ClinicalOrderType.ecg]),
  referral('Referrals', [ClinicalOrderType.referral]);

  const OrderKind(this.label, this.types);

  final String label;
  final List<ClinicalOrderType> types;
}

class OrderKindFilter extends Notifier<OrderKind> {
  @override
  OrderKind build() => OrderKind.all;

  void set(OrderKind kind) => state = kind;
}

final orderKindProvider = NotifierProvider<OrderKindFilter, OrderKind>(OrderKindFilter.new);

/// Open orders of the chosen kind, most urgent first, then oldest.
final worklistProvider = FutureProvider.autoDispose<List<ClinicalOrder>>((ref) {
  ref.watch(ordersVersionProvider);
  return ref.watch(clinicalOrderRepositoryProvider).worklist(types: ref.watch(orderKindProvider).types);
});

final orderProvider = FutureProvider.autoDispose.family<ClinicalOrder, String>((ref, id) {
  ref.watch(ordersVersionProvider);
  return ref.watch(clinicalOrderRepositoryProvider).get(id);
});
