/// Wording of the requests to HR (late arrival, overtime).
abstract final class StaffRequestText {
  static const myRequests = 'My requests';
  static const withdrawWarning = 'HR will not decide it. You can ask about the same day again later.';
  static const noRequestsHint = 'Ask HR to excuse a late arrival or to pay your overtime from a day above.';
  static const reasonOptional = 'Reason (optional)';
  static const sendToHr = 'Send to HR';
  static const inOut = 'In – out';
  static const code = 'Code';

  static String withdrawTitle(String code) => 'Withdraw $code?';
  static String onDay(String date) => 'on $date';

  static const askHr = 'Ask HR about a day';
  static const lateSpan = 'Late ';
  static const overtimeSpan = 'Overtime ';
  static const excuseMyLateArrival = 'Excuse my late arrival';
  static const payMyOvertime = 'Pay my overtime';
  static const lateHint = 'Late minutes are deducted from your pay unless HR accepts your excuse.';
  static const overtimeHint = "Overtime is paid once HR approves it, at the clinic's overtime rate per hour.";
  static const lateReasonHint = 'e.g. traffic, a sick child';
  static const overtimeReasonHint = 'e.g. an emergency patient, covering a colleague';
  static const excused = 'Excused';
  static const deducted = 'Deducted';
  static const paid = 'Paid';
  static const notPaid = 'Not paid';
  static const approved = 'Approved';
  static const nothingToAsk =
      'Nothing to ask about: no late arrivals or unpaid overtime in the last 31 days, or HR '
      'has these requests switched off.';
  static String sentToHr(String code) => 'Sent to HR — $code.';
  static String checkInOut(String checkIn, String checkOut) => 'In $checkIn · Out $checkOut';
}
