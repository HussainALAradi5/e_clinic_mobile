import 'dart:async';

import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/app_lock_controller.dart';
import '../../application/session_controller.dart';
import '../widgets/two_factor_sheets.dart';

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

class _ChangePasswordSheet extends ConsumerStatefulWidget {
  const _ChangePasswordSheet();

  @override
  ConsumerState<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends ConsumerState<_ChangePasswordSheet> {
  final _form = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    for (final c in [_current, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_form.currentState?.validate() ?? false)) throw const ActionCancelled();
    await ref
        .read(authRepositoryProvider)
        .changePassword(currentPassword: _current.text, password: _password.text, passwordConfirmation: _confirm.text);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + MediaQuery.viewInsetsOf(context).bottom),
    child: Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Change password', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          PasswordField(
            controller: _current,
            label: 'Current password',
            validator: (v) => (v ?? '').isEmpty ? 'Enter your current password.' : null,
          ),
          const SizedBox(height: 16),
          NewPasswordFields(password: _password, confirm: _confirm),
          const SizedBox(height: 24),
          AppButton(label: 'Save new password', expand: true, lock: ButtonLock.once, onPressed: _save),
        ],
      ),
    ),
  );
}

/// Two-step sign-in: on / off with its sheet; roles that must keep it cannot turn it off.
class _TwoFactorTile extends StatelessWidget {
  const _TwoFactorTile({required this.state});

  final TwoFactorState state;

  Future<void> _open(BuildContext context, Widget sheet, String done) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => sheet,
    );
    if ((changed ?? false) && context.mounted) AppSnack.success(context, done);
  }

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(state.enabled ? Icons.verified_user_rounded : Icons.shield_outlined),
    title: const Text('Two-step sign-in'),
    subtitle: Text(switch ((state.enabled, state.mandatory)) {
      (true, true) => 'On — your role requires it.',
      (true, false) => 'On — a code from your authenticator app at sign-in.',
      (false, true) => 'Your role requires it: turn it on now.',
      (false, false) => 'Off — add a code from an authenticator app at sign-in.',
    }),
    trailing: state.enabled && state.mandatory ? null : const Icon(Icons.chevron_right_rounded),
    onTap: switch ((state.enabled, state.mandatory)) {
      (true, true) => null,
      (true, false) => () => _open(context, const TwoFactorDisableSheet(), 'Two-step sign-in is off.'),
      _ => () => _open(context, const TwoFactorSetupSheet(), 'Two-step sign-in is on.'),
    },
  );
}
