import 'package:freezed_annotation/freezed_annotation.dart';

import '../../enums/billing/invoice_payment_state.dart';
import '../../enums/billing/invoice_status.dart';
import '../../enums/billing/payment_method.dart';
import '../shared/money.dart';

part 'invoice.freezed.dart';
part 'invoice.g.dart';

part 'invoice_invoice_item.dart';
part 'invoice_payment.dart';

/// Mirror of InvoiceResource — lines and payments on the detail only.
@freezed
abstract class Invoice with _$Invoice {
  const factory Invoice({
    required String id,
    required String code,
    String? invoiceNumber,
    String? issueDate,
    String? dueDate,
    required Money total,
    required Money paidAmount,
    required Money balanceDue,
    @JsonKey(unknownEnumValue: InvoiceStatus.unknown) required InvoiceStatus status,

    /// Unpaid, overdue, partly paid, paid, refunded … (worked out by the server).
    @JsonKey(unknownEnumValue: InvoicePaymentState.unknown)
    @Default(InvoicePaymentState.unknown)
    InvoicePaymentState paymentState,

    /// How it was paid: methods of its completed payments.
    @JsonKey(unknownEnumValue: PaymentMethod.unknown) @Default([]) List<PaymentMethod> paymentMethods,
    @Default([]) List<InvoiceItem> items,
    @Default([]) List<Payment> payments,
  }) = _Invoice;

  const Invoice._();

  factory Invoice.fromJson(Map<String, dynamic> json) => _$InvoiceFromJson(json);

  String get number => invoiceNumber ?? code;

  bool get owing => balanceDue.isPositive;

  /// Share already paid, 0–1 (exact, in fils); a zero invoice counts as paid.
  double get paidShare => total.minor <= 0 ? 1 : ((total.minor - balanceDue.minor.clamp(0, total.minor)) / total.minor);
}
