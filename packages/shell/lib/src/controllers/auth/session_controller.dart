import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_lock_controller.dart';

/// A sign-in waiting for its two-factor code (memory only — never stored).
class TwoFactorChallenge {
  const TwoFactorChallenge({required this.token, required this.email});

  final String token;
  final String email;
}

/// The signed-in session: restored from the stored token on start (GET /auth/me), null when signed out.
class SessionController extends AsyncNotifier<Session?> {
  TokenStore get _tokens => ref.read(tokenStoreProvider);
  AuthRepository get _auth => ref.read(authRepositoryProvider);
  String get _deviceName => AppConfig.deviceName;

  @override
  Future<Session?> build() async {
    if (await _tokens.read() == null) return null;
    try {
      return await _auth.me();
    } on ApiException catch (error) {
      if (error.status == 401) {
        await _tokens.clear();
        return null;
      }
      rethrow;
    }
  }

  /// Signs in; returns a challenge when the account needs a two-factor code first.
  Future<TwoFactorChallenge?> login(String email, String password) async {
    try {
      await _start(await _auth.login(email: email.trim(), password: password, deviceName: _deviceName));
      return null;
    } on ApiException catch (error) {
      final token = error.meta['challenge_token'];
      if (error.code == ErrorCodes.twoFactorRequired && token is String) {
        return TwoFactorChallenge(token: token, email: email.trim());
      }
      rethrow;
    }
  }

  Future<void> verifyTwoFactor(TwoFactorChallenge challenge, String code, {required bool isRecoveryCode}) async =>
      _start(
        await _auth.twoFactorChallenge(
          challengeToken: challenge.token,
          code: code.trim(),
          isRecoveryCode: isRecoveryCode,
          deviceName: _deviceName,
        ),
      );

  /// Signs out this device (the server revokes the token even if the call fails, it expires anyway).
  Future<void> logout() async {
    try {
      await _auth.logout();
    } on ApiException {
      // Offline or already revoked: still clear the device.
    }
    await _end();
  }

  /// Revokes every token of the account, including this one.
  Future<void> logoutAll() async {
    await _auth.logoutAll();
    await _end();
  }

  /// Reloads the signed-in user (after a change to the account, such as two-step sign-in).
  Future<void> refresh() async {
    final session = await _auth.me();
    state = AsyncData(session.copyWith(token: null));
  }

  /// The server rejected the token (revoked elsewhere or expired).
  Future<void> expire() async {
    if (state.value != null) await _end();
  }

  Future<void> _start(Session session) async {
    final token = session.token;
    if (token == null) throw StateError('The server did not return a token.');
    await _tokens.write(token);
    ref.read(appLockProvider.notifier).unlocked();
    state = AsyncData(session.copyWith(token: null));
  }

  Future<void> _end() async {
    await _tokens.clear();
    state = const AsyncData(null);
  }
}

final sessionProvider = AsyncNotifierProvider<SessionController, Session?>(SessionController.new);

/// Permission expressions against the signed-in user (UI convenience; the server enforces).
final accessProvider = Provider<Access>((ref) {
  final session = ref.watch(sessionProvider).value;
  return session == null ? Access.guest : Access(session.permissions.toSet(), signedIn: true);
});

/// The current user, or null when signed out.
final currentUserProvider = Provider<User?>((ref) => ref.watch(sessionProvider).value?.user);
