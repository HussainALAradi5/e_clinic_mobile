/// Text of the staff patient file on the phone.
abstract final class PatientDetailText {
  static const title = 'Patient file';
  static const medicalHistory = 'Medical history';
  static const historySaved = 'Medical history saved.';
  static const details = 'Details';
  static const comingVisits = 'Coming visits';
  static const noVisits = 'No visits booked.';
  static const history = 'History';
  static const book = 'Book a visit';
  static String age(int years) => '$years years';
}
