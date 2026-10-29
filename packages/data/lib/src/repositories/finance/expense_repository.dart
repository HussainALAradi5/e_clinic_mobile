import 'package:e_clinic_core/core.dart';
import '../../models/finance/expense.dart';

class ExpenseRepository {
  const ExpenseRepository(this._api);

  final ApiClient _api;

  Future<Paged<Expense>> list(ListQuery query) => _api.list('finance/expenses', query, Expense.fromJson);

  Future<Expense> approve(String id) => _api.post('finance/expenses/$id/approve', objectOf(Expense.fromJson));

  Future<Expense> reject(String id, String reason) =>
      _api.post('finance/expenses/$id/reject', objectOf(Expense.fromJson), body: {'reason': reason});
}
