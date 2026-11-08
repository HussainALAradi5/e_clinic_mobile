/// Wording of the staff day, calendar and visit cards.
abstract final class AppointmentText {
  static const calendar = 'Calendar';
  static const book = 'Book';
  static const nothingBooked = 'Nothing booked';
  static const mine = 'Mine';
  static const workspaceHint = 'Notes, orders and prescriptions are in the visit workspace on the clinic website.';
  static const type = 'Type';
  static const provider = 'With';
  static const service = 'Service';
  static const bookedVia = 'Booked via';
  static const noSchedule = 'Your work is on the other tabs';
  static const noScheduleHint = 'Your role has no patient bookings. Use the tabs below for the rest of your work.';
  static const completeVisit = 'Complete this visit?';
  static const suggestFollowUp = 'Suggest a follow-up';
  static const complete = 'Complete';

  static const booking = 'Booking';
  static const showWholeClinic = 'Show the whole clinic';
  static const showOnlyMine = 'Show only mine';
  static const mySchedule = 'My schedule';
  static const clinicSchedule = 'Clinic schedule';
  static const nothingBookedToday = 'Nothing booked today';
  static const noBookingsHere = 'No bookings here';
  static const noneBookedWithYou = 'No patients are booked with you today.';
  static const noneBookedInClinic = 'The clinic has no bookings today.';
  static const pickAnotherStage = 'Pick another stage to see the rest of the day.';
  static const none = 'None';
  static String lateBy(String minutes) => 'Late $minutes';
  static String waitingFor(String minutes) => 'Waiting $minutes';
  static String session(int n) => 'Session $n';
  static const providerFallback = 'Provider';
}
