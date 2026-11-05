/// Wording of the staff leave requests.
abstract final class LeaveText {
  static const myLeave = 'My leave';
  static const requestLeave = 'Request leave';
  static const halfDay = 'Half day';
  static const withdrawThisRequest = 'Withdraw this request?';
  static const certificate = 'Certificate';

  static const thisYear = 'This year';
  static const noBalances = 'No leave balances set up for you yet.';
  static const draftSaved = 'Saved. Attach a photo of the certificate, then send it.';
  static const sent = 'Sent to your manager.';
  static const kindOfLeave = 'Kind of leave';
  static const days = 'Days';
  static const saveDraft = 'Save draft';
  static const sendRequest = 'Send request';
  static const chooseKindAndDays = 'Choose the kind and the days';
  static const noLimit = 'No limit';
  static const daysOff = 'Days off';
  static const chooseTheDays = 'Choose the days';
  static const leave = 'Leave';
  static const certificateAttached = 'Certificate attached — send it to your manager.';
  static const attachCertificate = 'Attach a photo of the certificate, then send it to your manager.';
  static const needsCertificate =
      'Needs a certificate: the request is saved as a draft until you attach a photo of it.';
  static String managerNote(String note) => 'Manager: $note';
  static String noticeDays(int days) => 'Ask at least $days days ahead.';
}
