import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_features/features.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bumped after a request, submit or cancel, so my requests and balances reload.
class LeavesVersion extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

final leavesVersionProvider = NotifierProvider<LeavesVersion, int>(LeavesVersion.new);

/// My leave requests, newest first (a staff account and its employee record share one id).
final myLeavesProvider = FutureProvider.autoDispose<List<LeaveRequest>>((ref) async {
  ref.watch(leavesVersionProvider);
  final me = ref.watch(currentUserProvider)?.id;
  if (me == null) return const [];
  final page = await ref
      .watch(leaveRepositoryProvider)
      .list(ListQuery(perPage: 50, sort: const ['-startDate'], filter: AllOf([Where.eq('employeeId', me)])));
  return page.items;
});

/// My days per leave type this year.
final myBalancesProvider = FutureProvider.autoDispose<List<LeaveBalance>>((ref) {
  ref.watch(leavesVersionProvider);
  final me = ref.watch(currentUserProvider)?.id;
  if (me == null) return const [];
  return ref.watch(leaveRepositoryProvider).balances(me);
});

/// Leave types that can still be requested.
final leaveTypesProvider = FutureProvider.autoDispose<List<LeaveType>>((ref) async {
  final types = await ref.watch(leaveRepositoryProvider).types();
  return types.where((t) => !t.isArchived).toList();
});
