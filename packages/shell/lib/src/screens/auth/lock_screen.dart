import 'dart:async';

import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/auth/app_lock_controller.dart';
import '../../controllers/auth/session_controller.dart';

/// `/lock` — fingerprint / face unlock after the app was in the background; asks once on open.
/// After [AppLockController.maxFailures] failures the user signs in with the password again.
class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_unlock()));
  }

  Future<void> _unlock() async {
    final lock = ref.read(appLockProvider.notifier);
    if (await lock.unlock()) return;
    if (lock.failures >= AppLockController.maxFailures) {
      await ref.read(sessionProvider.notifier).logout();
      if (mounted) AppSnack.info(context, 'Please sign in with your password.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final user = ref.watch(currentUserProvider);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Spacer(),
              CircleAvatar(
                radius: 40,
                backgroundColor: scheme.primaryContainer,
                child: Text(
                  initials(user?.fullName ?? ''),
                  style: theme.textTheme.headlineSmall?.copyWith(color: scheme.onPrimaryContainer),
                ),
              ),
              const SizedBox(height: 20),
              Text('Welcome back, ${user?.firstName ?? ''}', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                'e-Clinic is locked to keep your health information private.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const Spacer(),
              FilledButton.icon(
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                onPressed: _unlock,
                icon: const Icon(Icons.fingerprint_rounded),
                label: const Text('Unlock'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.read(sessionProvider.notifier).logout(),
                child: const Text('Sign in with password instead'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
