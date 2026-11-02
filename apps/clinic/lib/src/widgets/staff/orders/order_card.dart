import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_shell/shell.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes/staff_paths.dart';
import '../../../controllers/staff/order_actions.dart';
import 'order_action_button.dart';

/// An order on the work list: what, for whom, who ordered it and when, priority and status, and the next step
/// as a button (cancel under ⋯). Tapping opens the order.
class OrderCard extends ConsumerWidget {
  const OrderCard({super.key, required this.order});

  final ClinicalOrder order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final actions = OrderAction.available(order, ref.watch(accessProvider));
    final primary = OrderAction.primary(actions);
    final others = actions.where((a) => a != primary).toList();
    final ordered = [
      if (order.orderingDoctor != null) order.orderingDoctor!.fullName,
      if (order.createdAt != null) ClinicClock.ago(order.createdAt!),
    ].join(' · ');
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(StaffPaths.order(order.id)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order.description, style: theme.textTheme.titleMedium),
                        if (order.patient != null)
                          Text(
                            [order.patient!.fullName, order.patient!.code].whereType<String>().join(' · '),
                            style: theme.textTheme.bodyMedium,
                          ),
                        if (ordered.isNotEmpty) Text(ordered, style: theme.textTheme.bodySmall?.copyWith(color: muted)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            StatusChip(enumName: 'GenericStatus', value: order.status),
                            if (order.priority != 'medium')
                              StatusChip(enumName: 'TreatmentPriority', value: order.priority),
                            if (order.room != null)
                              Chip(
                                visualDensity: VisualDensity.compact,
                                avatar: const Icon(Icons.meeting_room_outlined, size: 16),
                                label: Text(order.room!.name),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (others.isNotEmpty)
                    PopupMenuButton<OrderAction>(
                      tooltip: 'More actions',
                      onSelected: (action) => OrderActions.runFromMenu(context, ref, action, order),
                      itemBuilder: (_) => [
                        for (final action in others)
                          PopupMenuItem(
                            value: action,
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(action.icon),
                              title: Text(action.label),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
              if (primary != null) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: OrderActionButton(
                    action: primary,
                    order: order,
                    expand: true,
                    variant: primary == OrderAction.start ? ButtonVariant.tonal : ButtonVariant.filled,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
