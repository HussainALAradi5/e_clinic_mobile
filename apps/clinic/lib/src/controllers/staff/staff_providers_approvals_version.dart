part of 'staff_providers.dart';

/// Bumped after a decision, so the approvals list and the tab badge reload.
class ApprovalsVersion extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}
