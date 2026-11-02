import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../controllers/staff/order_actions.dart';

/// The button of one order step: asks first (the result, a reason), then locks for the call only.
class OrderActionButton extends ConsumerStatefulWidget {
  const OrderActionButton({
    super.key,
    required this.action,
    required this.order,
    this.variant = ButtonVariant.filled,
    this.expand = false,
  });

  final OrderAction action;
  final ClinicalOrder order;
  final ButtonVariant variant;
  final bool expand;

  @override
  ConsumerState<OrderActionButton> createState() => _OrderActionButtonState();
}

class _OrderActionButtonState extends ConsumerState<OrderActionButton> {
  OrderInput? _input;

  Future<bool> _ask() async {
    _input = await OrderActions.ask(context, widget.action, widget.order);
    return _input != null;
  }

  @override
  Widget build(BuildContext context) => AppButton(
    label: widget.action.label,
    icon: widget.action.icon,
    variant: widget.variant,
    expand: widget.expand,
    before: _ask,
    onPressed: () => OrderActions.run(context, ref, widget.action, widget.order, _input!),
  );
}
