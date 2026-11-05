import 'package:e_clinic_data/data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/staff/order_action_text.dart';

part 'order_providers_order_kind.dart';
part 'order_providers_order_kind_filter.dart';

/// Bumped after a start, complete or cancel, so the work list and the order reload.
class OrdersVersion extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

final ordersVersionProvider = NotifierProvider<OrdersVersion, int>(OrdersVersion.new);

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
