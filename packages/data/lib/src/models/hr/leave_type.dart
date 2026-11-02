import 'package:freezed_annotation/freezed_annotation.dart';

part 'leave_type.freezed.dart';
part 'leave_type.g.dart';

part 'leave_type_leave_balance.dart';

/// Mirror of LeaveTypeResource — annual, sick, emergency …
@freezed
abstract class LeaveType with _$LeaveType {
  const factory LeaveType({
    required String id,
    String? code,
    required String name,
    @Default(true) bool isPaid,
    @Default(true) bool isLimited,

    /// Sick leave: a certificate must be attached before the request can be sent.
    @Default(false) bool requiresAttachment,
    @Default(0) int minNoticeDays,
    @Default(false) bool isArchived,
  }) = _LeaveType;

  factory LeaveType.fromJson(Map<String, dynamic> json) => _$LeaveTypeFromJson(json);
}
