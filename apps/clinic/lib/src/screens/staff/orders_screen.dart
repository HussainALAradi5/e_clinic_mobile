import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/staff/order_text.dart';
import '../../controllers/staff/order_providers.dart';
import '../../widgets/staff/orders/order_card.dart';

/// `/clinic/clinical-orders` — the work list of open orders (X-ray, scans, lab, ECG, referrals), most urgent
/// first: start one when the patient is in, write the result when done.
class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kind = ref.watch(orderKindProvider);
    final orders = ref.watch(worklistProvider);
    return Scaffold(
      appBar: AppBar(title: const Text(OrderText.orderWorkList)),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(worklistProvider);
          await ref.read(worklistProvider.future);
        },
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            const SizedBox(height: 4),
            ChipBar<OrderKind>(
              options: [for (final k in OrderKind.values) (value: k, label: k.label, count: null)],
              selected: kind,
              onSelected: ref.read(orderKindProvider.notifier).set,
            ),
            const SizedBox(height: 12),
            orders.when(
              loading: () => const SkeletonList(count: 3, height: 150),
              error: (error, _) => ErrorState(error: error, onRetry: () => ref.invalidate(worklistProvider)),
              data: (list) => list.isEmpty
                  ? const EmptyState(
                      icon: Icons.biotech_outlined,
                      title: OrderText.allDone,
                      message: OrderText.allDoneHint,
                    )
                  : Column(
                      children: [
                        for (final order in list)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            child: OrderCard(order: order),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
