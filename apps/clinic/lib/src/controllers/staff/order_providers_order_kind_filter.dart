part of 'order_providers.dart';

class OrderKindFilter extends Notifier<OrderKind> {
  @override
  OrderKind build() => OrderKind.all;

  void set(OrderKind kind) => state = kind;
}
