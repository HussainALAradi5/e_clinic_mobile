part of 'session_controller.dart';

/// A sign-in waiting for its two-factor code (memory only — never stored).
class TwoFactorChallenge {
  const TwoFactorChallenge({required this.token, required this.email});

  final String token;
  final String email;
}
