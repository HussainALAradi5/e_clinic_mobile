/// Messages shown when a request to the clinic server fails.
abstract final class ApiErrorText {
  static const offline = 'You seem to be offline. Check your connection and try again.';
  static const unexpected = 'Something went wrong. Please try again.';
  static const tooMany = 'Too many attempts. Please wait a moment and try again.';
  static String tooManyWait(int seconds) => 'Too many attempts. Try again in $seconds seconds.';
  static const serverProblem = 'The clinic server had a problem. Please try again shortly.';
  static const unreadable = 'The clinic server sent an answer the app could not read.';
}
