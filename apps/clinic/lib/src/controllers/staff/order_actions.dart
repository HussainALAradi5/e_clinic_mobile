import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/staff/order_action_text.dart';
import '../../widgets/staff/orders/complete_order_sheet.dart';
import 'order_providers.dart';

part 'order_actions_no_input.dart';
part 'order_actions_order_action.dart';
part 'order_actions_order_input.dart';
part 'order_actions_reason_input.dart';
part 'order_actions_result_input.dart';

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
            title: OrderActionText.cancelTitle(order.code),
            message: order.description,
            confirmLabel: OrderActionText.cancelOrder,
            cancelLabel: OrderActionText.keep,
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
    OrderAction.start => OrderActionText.started(order.code),
    OrderAction.complete => OrderActionText.resultSaved(order.patient?.fullName),
    OrderAction.cancel => OrderActionText.cancelled(order.code),
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
