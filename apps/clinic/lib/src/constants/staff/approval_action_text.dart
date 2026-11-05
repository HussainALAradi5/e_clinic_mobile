/// Wording of the approve / reject confirmations and their results.
abstract final class ApprovalActionText {
  static const approve = 'Approve';
  static const reject = 'Reject';
  static const rejectRequest = 'Reject this request?';
  static const rejectReasonHint = 'The person who asked sees your reason.';
  static const staffMember = 'Staff member';
  static const thePatient = 'the patient';
  static const thisPerson = 'this person';
  static const refundTitle = 'Approve this refund?';
  static String refundMessage(String amount, String patient) => '$amount to $patient. The cashier can then pay it out.';
  static const refundApproved = 'Refund approved.';
  static const refundReject = 'Reject this refund?';
  static const expenseTitle = 'Approve this expense?';
  static String expenseMessage(String amount, String what) => '$amount — $what.';
  static const expenseApproved = 'Expense approved.';
  static const expenseReject = 'Reject this expense?';
  static const leaveTitle = 'Approve this leave?';
  static String leaveMessage(String name, String days) => '$name, $days. The days leave their balance and their schedule is blocked.';
  static String leaveHasBookings(String name) => '$name has bookings on those days';
  static const leaveCancelBookings = 'Approve and cancel those bookings? The patients are told and can book again.';
  static const leaveCancelConfirm = 'Approve and cancel bookings';
  static const keepAsIs = 'Keep as it is';
  static const leaveApproved = 'Leave approved.';
  static const leaveReject = 'Reject this leave?';
  static const overtimeTitle = 'Approve the overtime?';
  static String overtimeMessage(String name, String minutes, String date) =>
      "$name: $minutes on $date. It is paid with the month's payroll.";
  static const overtimeApproved = 'Overtime approved.';
  static String onDay(String date) => ' on $date';
  static const lateTitle = 'Excuse the late arrival?';
  static const payOvertimeTitle = 'Pay the overtime?';
  static String lateMessage(String name, String minutes, String day, String? amount) =>
      '$name: $minutes late$day. It will not be deducted${amount == null ? '' : ' ($amount)'}.';
  static String payOvertimeMessage(String name, String minutes, String day, String? amount) =>
      "$name: $minutes$day${amount == null ? '' : ', $amount'}. It is paid with the month's payroll.";
  static const lateExcused = 'Late arrival excused.';
  static const lateReject = 'Reject the excuse?';
  static const overtimeReject = 'Reject the overtime?';
}
