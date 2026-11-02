/// Stable `error_code` values of the server error envelope that the apps react to. Switch on these, never on text.
abstract final class ErrorCodes {
  static const unauthenticated = 'UNAUTHENTICATED';
  static const forbidden = 'FORBIDDEN';
  static const notFound = 'NOT_FOUND';
  static const validationFailed = 'VALIDATION_FAILED';
  static const tooManyRequests = 'TOO_MANY_REQUESTS';
  static const concurrentModification = 'CONCURRENT_MODIFICATION';
  static const invalidCredentials = 'AUTH_INVALID_CREDENTIALS';
  static const accountLocked = 'AUTH_ACCOUNT_LOCKED';
  static const accountInactive = 'AUTH_ACCOUNT_INACTIVE';
  static const twoFactorRequired = 'AUTH_2FA_REQUIRED';
  static const twoFactorInvalid = 'AUTH_2FA_INVALID';
  static const resetTokenInvalid = 'AUTH_RESET_TOKEN_INVALID';
  static const slotUnavailable = 'SLOT_UNAVAILABLE';
  static const doctorNotAvailable = 'DOCTOR_NOT_AVAILABLE';
  static const patientDoubleBooked = 'PATIENT_DOUBLE_BOOKED';
  static const bookingWindowExceeded = 'BOOKING_WINDOW_EXCEEDED';
  static const scanCodeInvalid = 'SCAN_CODE_INVALID';
  static const selfApprovalNotAllowed = 'SELF_APPROVAL_NOT_ALLOWED';

  /// Approving leave would leave booked visits on a day off; ask, then retry with `cancel_affected`.
  static const scheduleHasAppointments = 'SCHEDULE_HAS_APPOINTMENTS';

  /// Client-side: no connection or the server could not be reached.
  static const offline = 'OFFLINE';

  /// Client-side: an answer the app could not read.
  static const unexpected = 'UNEXPECTED';
}
