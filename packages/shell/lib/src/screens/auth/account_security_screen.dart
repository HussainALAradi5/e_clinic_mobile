import 'dart:async';

import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/auth/app_lock_controller.dart';
import '../../controllers/auth/session_controller.dart';
import '../../widgets/auth/two_factor_sheets.dart';

part 'account_security_screen_change_password_sheet.dart';
part 'account_security_screen_change_password_sheet_state.dart';
part 'account_security_screen_two_factor_tile.dart';

/// `/account/security` — change password, two-step sign-in, app lock with fingerprint / face, sign out everywhere.
class AccountSecurityScreen extends ConsumerWidget {
  const AccountSecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final lockOn = ref.watch(appLockProvider.select((lock) => lock.enabled));
    final twoFactor = ref.watch(sessionProvider).value?.user.twoFactor ?? const TwoFactorState();
    return Scaffold(
      appBar: AppBar(title: const Text('Password & security')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.password_rounded),
                  title: const Text('Change password'),
                  subtitle: const Text('You will stay signed in on this device.'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _changePassword(context),
                ),
                const Divider(indent: 16, endIndent: 16),
                _TwoFactorTile(state: twoFactor),
                const Divider(indent: 16, endIndent: 16),
                FutureBuilder<bool>(
                  future: ref.read(appLockProvider.notifier).available,
                  builder: (context, snapshot) => SwitchListTile(
                    secondary: const Icon(Icons.fingerprint_rounded),
                    title: const Text('Lock with fingerprint or face'),
                    subtitle: Text(
                      snapshot.data == false
                          ? 'Set up a fingerprint, face or screen lock on this phone first.'
                          : 'Asked when you open the app and after a few minutes away.',
                    ),
                    value: lockOn,
                    onChanged: snapshot.data == true
                        ? (value) => unawaited(ref.read(appLockProvider.notifier).setEnabled(value))
                        : null,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Signed-in devices', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Lost a phone or used a shared computer? Sign out everywhere, then sign in again here.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Sign out of all devices',
            icon: Icons.logout_rounded,
            variant: ButtonVariant.outlined,
            confirm: const ConfirmConfig(
              title: 'Sign out everywhere?',
              message:
                  'Every phone and browser signed in to your account, including this one, will need to sign in again.',
              confirmLabel: 'Sign out everywhere',
              danger: true,
            ),
            onPressed: () => ref.read(sessionProvider.notifier).logoutAll(),
          ),
        ],
      ),
    );
  }

  Future<void> _changePassword(BuildContext context) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _ChangePasswordSheet(),
    );
    if ((saved ?? false) && context.mounted) AppSnack.success(context, 'Your password is changed.');
  }
}
