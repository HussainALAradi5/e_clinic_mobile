import 'package:e_clinic_core/core.dart';

import '../../models/identity/user.dart';

/// Identity › Authentication — one method per endpoint; errors arrive as [ApiException].
class AuthRepository {
  const AuthRepository(this._api);

  final ApiClient _api;

  /// Throws [ApiException] with [ErrorCodes.twoFactorRequired] and `meta['challenge_token']` when a code is needed.
  Future<Session> login({required String email, required String password, required String deviceName}) => _api.post(
    'auth/login',
    objectOf(Session.fromJson),
    body: {'email': email, 'password': password, 'device_name': deviceName},
  );

  /// A 6-digit TOTP code, or a recovery code.
  Future<Session> twoFactorChallenge({
    required String challengeToken,
    required String code,
    required bool isRecoveryCode,
    required String deviceName,
  }) => _api.post(
    'auth/two-factor/challenge',
    objectOf(Session.fromJson),
    body: {
      'challenge_token': challengeToken,
      (isRecoveryCode ? 'recovery_code' : 'code'): code,
      'device_name': deviceName,
    },
  );

  Future<Session> me() => _api.get('auth/me', objectOf(Session.fromJson));

  Future<void> logout() => _api.post('auth/logout', ApiClient.ignore);

  Future<void> logoutAll() => _api.post('auth/logout-all', ApiClient.ignore);

  Future<void> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) => _api.put(
    'auth/password',
    ApiClient.ignore,
    body: {'current_password': currentPassword, 'password': password, 'password_confirmation': passwordConfirmation},
  );

  /// Starts two-step sign-in: the `otpauth://` link for an authenticator app (it holds the secret key).
  Future<String> enableTwoFactor() =>
      _api.post('auth/two-factor/enable', (data) => (data! as Map<String, dynamic>)['otpauth_url'] as String);

  /// Turns two-step sign-in on with a first code from the app; returns the one-time recovery codes.
  Future<List<String>> confirmTwoFactor(String code) => _api.post(
    'auth/two-factor/confirm',
    (data) => [for (final c in (data! as Map<String, dynamic>)['recovery_codes'] as List<dynamic>) c as String],
    body: {'code': code},
  );

  /// Turns it off after the password (refused for roles where it is mandatory).
  Future<void> disableTwoFactor(String password) => _api.delete('auth/two-factor', body: {'password': password});

  /// Sends a 6-digit code by email (the answer is the same whether or not the address exists).
  Future<void> forgotPassword(String email) =>
      _api.post('auth/forgot-password', ApiClient.ignore, body: {'email': email});

  /// Exchanges the emailed code for a one-time reset token.
  Future<String> verifyResetCode({required String email, required String code}) => _api.post(
    'auth/verify-reset-code',
    (data) => (data! as Map<String, dynamic>)['token'] as String,
    body: {'email': email, 'code': code},
  );

  /// Sets a new password (also completes a portal invitation).
  Future<void> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) => _api.post(
    'auth/reset-password',
    ApiClient.ignore,
    body: {'token': token, 'email': email, 'password': password, 'password_confirmation': passwordConfirmation},
  );
}
