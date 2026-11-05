/// Wording of the lab and imaging order work list.
abstract final class OrderText {
  static const orderWorkList = 'Order work list';
  static const allDone = 'All done';
  static const allDoneHint = 'No open orders of this kind.';
  static const abnormal = 'Abnormal';
  static const patient = 'Patient';
  static const orderedBy = 'Ordered by';
  static const ordered = 'Ordered';
  static const bodyPart = 'Body part';
  static const clinicalNotes = 'Clinical notes';
  static const performedBy = 'Performed by';
  static const completed = 'Completed';
  static const abnormalFinding = 'Abnormal finding';
  static const abnormalHint = 'The ordering doctor is alerted.';
  static const saveResult = 'Save result';

  static String resultOf(String code) => 'Result of $code';

  static const order = 'Order';
  static const result = 'Result';
  static const files = 'Files';
  static const addLetterPhoto = 'Add letter photo';
  static const addResultPhoto = 'Add result photo';
}
