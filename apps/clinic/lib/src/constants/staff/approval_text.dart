/// Wording of the approvals screen.
abstract final class ApprovalText {
  static const approvals = 'Approvals';
  static const allCaughtUp = 'All caught up';
  static const allCaughtUpHint = 'Nothing is waiting for your decision. Pull down to check again.';
  static const askedBy = 'Asked by';
  static const asked = 'Asked';
  static const whatFor = 'What for';
  static const date = 'Date';
  static const role = 'Role';
  static const documents = 'Documents';
  static const reject = 'Reject';
  static const approve = 'Approve';

  static const staffMember = 'Staff member';
  static const rejected = 'Rejected.';
  static String refundsCount(int n) => 'Refunds · $n';
  static String expensesCount(int n) => 'Expenses · $n';
  static String leavesCount(int n) => 'Leave · $n';
  static String requestsCount(int n) => 'Late & overtime · $n';
  static String overtimeCount(int n) => 'Overtime · $n';
}
