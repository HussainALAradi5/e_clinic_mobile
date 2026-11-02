import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../widgets/staff/orders/complete_order_sheet.dart';
import 'order_providers.dart';

/// Steps of a clinical order. One shows when the order may move to its target status **and** the user holds the
/// right (same expressions as the server routes, which check again).
enum OrderAction {
  start('Start', Icons.play_arrow_rounded, GenericStatus.inProgress, 'orders.write & orders.perform'),
  complete('Write result', Icons.task_alt_rounded, GenericStatus.completed, 'orders.write & orders.perform'),
  cancel('Cancel order', Icons.cancel_outlined, GenericStatus.cancelled, 'orders.write');

  const OrderAction(this.label, this.icon, this.target, this.access);

  final String label;
  final IconData icon;
  final GenericStatus target;
  final String access;

  /// What this user can do with the order now, the main step first.
  static List<OrderAction> available(ClinicalOrder order, Access access) => [
    for (final action in values)
      if (order.canMoveTo(action.target) && access.can(action.access)) action,
  ];

  /// The big button: start or write the result (cancelling stays in the menu).
  static OrderAction? primary(List<OrderAction> actions) => actions.where((a) => a != cancel).firstOrNull;
}

/// What a step needs from the user: the result to complete, the reason to cancel, nothing to start.
sealed class OrderInput {
  const OrderInput();
}

final class NoInput extends OrderInput {
  const NoInput();
}

final class ResultInput extends OrderInput {
  const ResultInput(this.result);

  final OrderResult result;
}

final class ReasonInput extends OrderInput {
  const ReasonInput(this.reason);

  final String reason;
}

abstract final class OrderActions {
  /// Asks what [action] needs before anything locks; null when the user backs out.
  static Future<OrderInput?> ask(BuildContext context, OrderAction action, ClinicalOrder order) async {
    switch (action) {
      case OrderAction.start:
        return const NoInput();
      case OrderAction.complete:
        final result = await showModalBottomSheet<OrderResult>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (_) => CompleteOrderSheet(order: order),
        );
        return result == null ? null : ResultInput(result);
      case OrderAction.cancel:
        final reason = await showReasonSheet(
          context,
          ConfirmConfig(
            title: 'Cancel ${order.code}?',
            message: order.description,
            confirmLabel: 'Cancel order',
            cancelLabel: 'Keep',
            danger: true,
          ),
        );
        return reason == null ? null : ReasonInput(reason);
    }
  }

  /// Calls the server for [action] with what [ask] returned, and returns the updated order.
  static Future<ClinicalOrder> run(
    BuildContext context,
    WidgetRef ref,
    OrderAction action,
    ClinicalOrder order,
    OrderInput input,
  ) async {
    final repository = ref.read(clinicalOrderRepositoryProvider);
    final updated = await switch (input) {
      ResultInput(:final result) => repository.complete(order.id, report: result.report, isAbnormal: result.abnormal),
      ReasonInput(:final reason) => repository.cancel(order.id, reason),
      NoInput() => repository.start(order.id),
    };
    ref.read(ordersVersionProvider.notifier).bump();
    if (context.mounted) AppSnack.success(context, _done(action, order));
    return updated;
  }

  /// The whole step from a menu (no button to lock).
  static Future<void> runFromMenu(BuildContext context, WidgetRef ref, OrderAction action, ClinicalOrder order) async {
    try {
      final input = await ask(context, action, order);
      if (input != null && context.mounted) await run(context, ref, action, order, input);
    } catch (error) {
      if (context.mounted) AppSnack.error(context, error);
    }
  }

  static String _done(OrderAction action, ClinicalOrder order) => switch (action) {
    OrderAction.start => '${order.code} started.',
    OrderAction.complete => 'Result saved. ${order.patient?.fullName ?? 'The patient'} can see it now.',
    OrderAction.cancel => '${order.code} cancelled.',
  };
}

/// Files go on an order while it is open or done (not once cancelled), for whoever may attach files to orders.
bool canAttach(ClinicalOrder order, Access access) =>
    order.status != GenericStatus.cancelled && access.can('attachments.create & orders.write');

/// What a photo on an order is: an image for scans, a result for lab and ECG, the letter for a referral.
AttachmentCategory resultCategory(ClinicalOrderType type) => switch (type) {
  ClinicalOrderType.labTest || ClinicalOrderType.ecg => AttachmentCategory.labResult,
  ClinicalOrderType.referral => AttachmentCategory.referralLetter,
  ClinicalOrderType.unknown => AttachmentCategory.clinicalDocument,
  _ => AttachmentCategory.xrayImage,
};
