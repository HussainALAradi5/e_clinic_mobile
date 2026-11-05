/// Wording of the patient's visit cards.
abstract final class VisitText {
  /// Shown instead of Cancel within 3 days of the visit: reception cancels it (e.g. in an emergency).
  static const callReception = 'To cancel now, call reception.';

  static const myVisits = 'My visits';
  static const reasonHint = 'e.g. knee pain for two weeks';
  static const bookAnotherVisit = 'Book another visit';
  static const noDoctors = 'No doctor takes online bookings here yet';
  static const noDoctorsHint = 'Call the clinic and the front desk will book you in.';
  static const treatments = 'Treatments';
  static const prescriptions = 'Prescriptions';
  static const yourNextVisit = 'Your next visit';
  static const checkInCode = 'Check-in code';
  static const noVisitsBooked = 'No visits booked';
  static const bookingHint = 'Pick a doctor and a free time — the clinic confirms your booking.';
  static const awaitingConfirmation = 'Waiting for the clinic to confirm.';

  static String cancelled(String? reason) => 'Cancelled: $reason';

  static const noUpcomingVisits = 'No upcoming visits';
  static const noVisitsToday = 'No visits today';
  static const noPastVisitsYet = 'No past visits yet';
  static const noMissedVisits = 'No missed visits';
  static const noVisitsYet = 'No visits yet';
  static const noVisitsHint = 'Book a visit and it will show here.';
  static const bookingSent = 'Booking sent. The clinic will confirm it shortly.';
  static const visitFor = 'What is the visit for?';
  static const specialty = 'Specialty';
  static const doctor = 'Doctor';
  static const notesForDoctor = 'Anything the doctor should know? (optional)';
  static const pickDoctorAndTime = 'Pick a doctor and a time';
  static const atAGlance = 'At a glance';
  static const newProblem = 'New problem';
  static const followUp = 'Follow-up';
  static const noTreatmentPlanRunning = 'No treatment plan running';
  static const nothingToCollect = 'Nothing to collect';
  static const noResultsYet = 'No results yet';
  static const nothingToPay = 'Nothing to pay';
  static const awaiting = 'Awaiting confirmation';
  static const confirmed = 'Confirmed';
}
