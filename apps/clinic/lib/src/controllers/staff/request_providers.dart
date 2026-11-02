import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_shell/shell.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bumped after asking or withdrawing, so my requests and the days I can ask about reload.
class RequestsVersion extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

final requestsVersionProvider = NotifierProvider<RequestsVersion, int>(RequestsVersion.new);

/// My late excuse and overtime requests, newest first.
final myRequestsProvider = FutureProvider.autoDispose<List<StaffRequest>>((ref) async {
  ref.watch(requestsVersionProvider);
  final me = ref.watch(currentUserProvider)?.id;
  if (me == null) return const [];
  final page = await ref
      .watch(staffRequestRepositoryProvider)
      .list(ListQuery(perPage: 50, sort: const ['-createdAt'], filter: AllOf([Where.eq('employeeId', me)])));
  return page.items;
});

/// My recent days with late minutes or overtime still open to ask about (only kinds HR has switched on).
final askableDaysProvider = FutureProvider.autoDispose<List<AskableDay>>((ref) {
  ref.watch(requestsVersionProvider);
  if (!ref.watch(accessProvider).can('staff_requests.create')) return const [];
  return ref.watch(staffRequestRepositoryProvider).askable();
});
