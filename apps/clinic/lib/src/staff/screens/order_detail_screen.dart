import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_features/features.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/attachment_list.dart';
import '../application/order_actions.dart';
import '../application/order_providers.dart';
import '../widgets/orders/order_action_button.dart';

/// `/clinic/clinical-orders/:id` — one order: what was asked and why, the result once written, its files, and
/// the steps this user may take (the main one as the bottom button).
class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(orderProvider(id));
    final access = ref.watch(accessProvider);
    final theme = Theme.of(context);
    final order = value.value;
    final actions = order == null ? const <OrderAction>[] : OrderAction.available(order, access);
    final primary = OrderAction.primary(actions);
    return Scaffold(
      appBar: AppBar(title: Text(order?.code ?? 'Order')),
      body: AsyncBody(
        value: value,
        onRetry: () => ref.invalidate(orderProvider(id)),
        data: (order) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            Text(order.description, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                StatusChip(enumName: 'GenericStatus', value: order.status),
                StatusChip(enumName: 'TreatmentPriority', value: order.priority),
                if (order.isAbnormal ?? false)
                  Chip(
                    visualDensity: VisualDensity.compact,
                    backgroundColor: theme.colorScheme.errorContainer,
                    avatar: Icon(Icons.priority_high_rounded, size: 16, color: theme.colorScheme.onErrorContainer),
                    label: Text('Abnormal', style: TextStyle(color: theme.colorScheme.onErrorContainer)),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              margin: EdgeInsets.zero,
              child: FactList(
                facts: [
                  (
                    label: 'Patient',
                    value: order.patient == null
                        ? null
                        : [order.patient!.fullName, order.patient!.code].whereType<String>().join(' · '),
                  ),
                  (label: 'Ordered by', value: order.orderingDoctor?.fullName),
                  (label: 'Ordered', value: order.createdAt == null ? null : ClinicClock.dateTime(order.createdAt!)),
                  (label: 'Body part', value: order.bodyPart),
                  (label: 'Clinical notes', value: order.clinicalNotes),
                  (label: 'Room', value: order.room?.name),
                  (label: 'Performed by', value: order.performer?.fullName),
                  (label: 'Started', value: order.startedAt == null ? null : ClinicClock.dateTime(order.startedAt!)),
                  (
                    label: 'Completed',
                    value: order.completedAt == null ? null : ClinicClock.dateTime(order.completedAt!),
                  ),
                  (label: 'Cancelled because', value: order.cancellationReason),
                ],
              ),
            ),
            if (order.report != null) ...[
              const SectionHeader('Result'),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText(order.report!, style: theme.textTheme.bodyMedium),
                      if (order.reporter != null) ...[
                        const SizedBox(height: 8),
                        Text('Reported by ${order.reporter!.fullName}', style: theme.textTheme.bodySmall),
                      ],
                    ],
                  ),
                ),
              ),
            ],
            if (order.attachments.isNotEmpty) ...[
              const SectionHeader('Files'),
              AttachmentList(files: order.attachments),
            ],
          ],
        ),
      ),
      bottomNavigationBar: order == null || actions.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: [
                    for (final action in actions.where((a) => a != primary)) ...[
                      OrderActionButton(action: action, order: order, variant: ButtonVariant.outlined),
                      const SizedBox(width: 8),
                    ],
                    if (primary != null)
                      Expanded(
                        child: OrderActionButton(action: primary, order: order, expand: true),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
