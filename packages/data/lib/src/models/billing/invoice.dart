import 'package:freezed_annotation/freezed_annotation.dart';

import '../../enums/billing/invoice_status.dart';
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
    @Default([]) List<InvoiceItem> items,
    @Default([]) List<Payment> payments,
  }) = _Invoice;

  const Invoice._();

  factory Invoice.fromJson(Map<String, dynamic> json) => _$InvoiceFromJson(json);

  String get number => invoiceNumber ?? code;

  bool get owing => balanceDue.isPositive;
}
