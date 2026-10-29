import 'package:freezed_annotation/freezed_annotation.dart';
import '../shared/money.dart';
import '../shared/refs.dart';

part 'expense.freezed.dart';
part 'expense.g.dart';

/// Mirror of ExpenseResource.
@freezed
abstract class Expense with _$Expense {
  const factory Expense({
    required String id,
    required String code,

    /// ExpenseCategory wire value.
    required String category,
    String? payeeName,
    String? description,
    required Money amount,
    required String expenseDate,
    required String status,
    PersonRef? submittedBy,
    DateTime? createdAt,
  }) = _Expense;

  factory Expense.fromJson(Map<String, dynamic> json) => _$ExpenseFromJson(json);
}
