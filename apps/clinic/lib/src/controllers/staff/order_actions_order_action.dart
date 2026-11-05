part of 'order_actions.dart';

/// Steps of a clinical order. One shows when the order may move to its target status **and** the user holds the
/// right (same expressions as the server routes, which check again).
enum OrderAction {
  start(OrderActionText.start, Icons.play_arrow_rounded, GenericStatus.inProgress, 'orders.write & orders.perform'),
  complete(OrderActionText.writeResult, Icons.task_alt_rounded, GenericStatus.completed, 'orders.write & orders.perform'),
  cancel(OrderActionText.cancelOrder, Icons.cancel_outlined, GenericStatus.cancelled, 'orders.write');

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
