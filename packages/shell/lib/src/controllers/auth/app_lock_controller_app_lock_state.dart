part of 'app_lock_controller.dart';

/// Whether the app lock is on, and whether the app is locked right now.
class AppLockState {
  const AppLockState({required this.enabled, required this.locked});

  final bool enabled;
  final bool locked;
}
