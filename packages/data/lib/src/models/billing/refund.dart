import 'package:freezed_annotation/freezed_annotation.dart';
import '../shared/money.dart';
import '../shared/refs.dart';

part 'refund.freezed.dart';
part 'refund.g.dart';

/// Mirror of RefundResource (what an approver needs to decide).
@freezed
abstract class Refund with _$Refund {
  const factory Refund({
    required String id,
    required String code,
    PatientRef? patient,
    required Money amount,

    /// PaymentMethod wire value.
    required String method,
    String? reason,

    /// ApprovalStatus wire value (`pending`, `approved` …).
    required String status,
    PersonRef? requestedBy,
    DateTime? createdAt,
  }) = _Refund;

  factory Refund.fromJson(Map<String, dynamic> json) => _$RefundFromJson(json);
}
