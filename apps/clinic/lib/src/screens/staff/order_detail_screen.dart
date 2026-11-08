import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_shell/shell.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/common/common_text.dart';
import '../../constants/staff/order_text.dart';
import '../../controllers/staff/order_actions.dart';
import '../../controllers/staff/order_providers.dart';
import '../../widgets/common/attach_photo_button.dart';
import '../../widgets/common/attachment_list.dart';
import '../../widgets/staff/activity/activity_log_section.dart';
import '../../widgets/staff/orders/order_action_button.dart';

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
      appBar: AppBar(title: Text(order?.code ?? OrderText.order)),
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
                    label: Text(OrderText.abnormal, style: TextStyle(color: theme.colorScheme.onErrorContainer)),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              margin: EdgeInsets.zero,
              child: FactList(
                facts: [
                  (
                    label: OrderText.patient,
                    value: order.patient == null
                        ? null
                        : [order.patient!.fullName, order.patient!.code].whereType<String>().join(' · '),
                  ),
                  (label: OrderText.orderedBy, value: order.orderingDoctor?.fullName),
                  (
                    label: OrderText.ordered,
                    value: order.createdAt == null ? null : ClinicClock.dateTime(order.createdAt!),
                  ),
                  (label: OrderText.bodyPart, value: order.bodyPart),
                  (label: OrderText.clinicalNotes, value: order.clinicalNotes),
                  (label: CommonText.room, value: order.room?.name),
                  (label: OrderText.performedBy, value: order.performer?.fullName),
                  (
                    label: CommonText.started,
                    value: order.startedAt == null ? null : ClinicClock.dateTime(order.startedAt!),
                  ),
                  (
                    label: OrderText.completed,
                    value: order.completedAt == null ? null : ClinicClock.dateTime(order.completedAt!),
                  ),
                  (label: CommonText.cancelledBecause, value: order.cancellationReason),
                ],
              ),
            ),
            if (order.report != null) ...[
              const SectionHeader(OrderText.result),
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
                        Text(CommonText.reportedBy(order.reporter!.fullName), style: theme.textTheme.bodySmall),
                      ],
                    ],
                  ),
                ),
              ),
            ],
            if (order.attachments.isNotEmpty || canAttach(order, access)) const SectionHeader(OrderText.files),
            if (order.attachments.isNotEmpty) AttachmentList(files: order.attachments),
            if (canAttach(order, access))
              Align(
                alignment: Alignment.centerLeft,
                child: AttachPhotoButton(
                  ownerType: 'clinical_order',
                  ownerId: order.id,
                  category: resultCategory(order.type),
                  label: order.type == ClinicalOrderType.referral ? OrderText.addLetterPhoto : OrderText.addResultPhoto,
                  onUploaded: (_) => ref.read(ordersVersionProvider.notifier).bump(),
                ),
              ),
            ActivityLogSection(entity: ActivityEntity.clinicalOrder, id: order.id),
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
