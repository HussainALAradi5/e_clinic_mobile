import 'package:e_clinic_core/core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import 'session_controller.dart';

part 'app_lock_controller_app_lock_state.dart';

/// Biometric app lock: on cold start and after [AppConfig.lockAfterFor] the signed-in account (staff lock sooner) in
/// the background, when the user turned it on.
/// Three failed unlocks fall back to signing in with the password.
class AppLockController extends Notifier<AppLockState> {
  static const _prefKey = 'ec.biometric_lock';
  static const maxFailures = 3;

  final _auth = LocalAuthentication();
  DateTime? _pausedAt;
  int _failures = 0;

  bool get _enabled => ref.read(preferencesProvider).getBool(_prefKey) ?? false;

  @override
  AppLockState build() => AppLockState(enabled: _enabled, locked: _enabled);

  /// The device has a fingerprint, face or device credential set up.
  Future<bool> get available async {
    try {
      return await _auth.isDeviceSupported() && await _auth.canCheckBiometrics;
    } on PlatformException {
      return false;
    }
  }

  /// Turns the lock on (after one successful check) or off.
  Future<bool> setEnabled(bool value) async {
    if (value && !await _authenticate('Confirm it is you to turn on the app lock')) return false;
    await ref.read(preferencesProvider).setBool(_prefKey, value);
    state = AppLockState(enabled: value, locked: false);
    return true;
  }

  void paused() => _pausedAt = DateTime.now();

  void resumed() {
    final since = _pausedAt;
    _pausedAt = null;
    final isPatient = ref.read(currentUserProvider)?.isPatient ?? true;
    final lockAfter = ref.read(appConfigProvider).lockAfterFor(isPatient: isPatient);
    if (state.enabled && since != null && DateTime.now().difference(since) >= lockAfter) {
      state = const AppLockState(enabled: true, locked: true);
    }
  }

  /// After a password sign-in the app is open.
  void unlocked() {
    _failures = 0;
    state = AppLockState(enabled: state.enabled, locked: false);
  }

  /// Asks for the fingerprint / face; returns false when it failed (see [failures]).
  Future<bool> unlock() async {
    final ok = await _authenticate('Unlock e-Clinic');
    if (ok) {
      unlocked();
    } else {
      _failures++;
    }
    return ok;
  }

  int get failures => _failures;

  Future<bool> _authenticate(String reason) async {
    try {
      return await _auth.authenticate(localizedReason: reason, options: const AuthenticationOptions(stickyAuth: true));
    } on PlatformException {
      return false;
    }
  }
}

final appLockProvider = NotifierProvider<AppLockController, AppLockState>(AppLockController.new);
