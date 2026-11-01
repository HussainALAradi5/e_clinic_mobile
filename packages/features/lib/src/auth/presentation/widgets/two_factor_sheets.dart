import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../application/session_controller.dart';
import 'code_field.dart';

/// The secret key inside an `otpauth://` link, for typing into an authenticator by hand.
String? otpSecret(String otpauthUrl) => Uri.tryParse(otpauthUrl)?.queryParameters['secret'];

/// Turns two-step sign-in on: add the account to an authenticator app on this phone (one tap, or the key by hand),
/// type its first code, then keep the recovery codes.
class TwoFactorSetupSheet extends ConsumerStatefulWidget {
  const TwoFactorSetupSheet({super.key});

  @override
  ConsumerState<TwoFactorSetupSheet> createState() => _TwoFactorSetupSheetState();
}

class _TwoFactorSetupSheetState extends ConsumerState<TwoFactorSetupSheet> {
  final _code = TextEditingController();
  late final Future<String> _link = ref.read(authRepositoryProvider).enableTwoFactor();
  List<String>? _recoveryCodes;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    if (_code.text.length != 6) throw const ActionCancelled();
    final codes = await ref.read(authRepositoryProvider).confirmTwoFactor(_code.text);
    await ref.read(sessionProvider.notifier).refresh();
    if (mounted) setState(() => _recoveryCodes = codes);
  }

  Future<void> _openAuthenticator(String link) async {
    if (!await launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication) && mounted) {
      AppSnack.info(context, 'No authenticator app found — add the key by hand.');
    }
  }

  void _copy(String text, String what) {
    Clipboard.setData(ClipboardData(text: text));
    AppSnack.success(context, '$what copied.');
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final codes = _recoveryCodes;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: codes != null
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Two-step sign-in is on', style: text.titleLarge),
                const SizedBox(height: 8),
                const InfoNote(
                  icon: Icons.key_rounded,
                  text: 'Keep these recovery codes somewhere safe. Each one signs you in once if you lose this phone.',
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final c in codes)
                      Chip(
                        label: SelectableText(c, style: const TextStyle(fontFamily: 'monospace')),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => _copy(codes.join('\n'), 'Recovery codes'),
                  icon: const Icon(Icons.copy_rounded),
                  label: const Text('Copy codes'),
                ),
                const SizedBox(height: 8),
                FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Done')),
              ],
            )
          : FutureBuilder<String>(
              future: _link,
              builder: (context, snapshot) {
                if (snapshot.hasError) return ErrorState(error: snapshot.error!);
                final link = snapshot.data;
                if (link == null) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final secret = otpSecret(link);
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Turn on two-step sign-in', style: text.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      '1. Add e-Clinic to an authenticator app (Google Authenticator, Microsoft Authenticator …).',
                      style: text.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    FilledButton.tonalIcon(
                      onPressed: () => _openAuthenticator(link),
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: const Text('Open authenticator app'),
                    ),
                    if (secret != null)
                      TextButton.icon(
                        onPressed: () => _copy(secret, 'Key'),
                        icon: const Icon(Icons.copy_rounded),
                        label: Text('Or copy the key: $secret', overflow: TextOverflow.ellipsis),
                      ),
                    const SizedBox(height: 12),
                    Text('2. Type the 6-digit code the app shows.', style: text.bodyMedium),
                    const SizedBox(height: 8),
                    CodeField(controller: _code),
                    const SizedBox(height: 16),
                    AppButton(label: 'Turn on', icon: Icons.verified_user_rounded, expand: true, onPressed: _confirm),
                  ],
                );
              },
            ),
    );
  }
}

/// Turns two-step sign-in off after the password.
class TwoFactorDisableSheet extends ConsumerStatefulWidget {
  const TwoFactorDisableSheet({super.key});

  @override
  ConsumerState<TwoFactorDisableSheet> createState() => _TwoFactorDisableSheetState();
}

class _TwoFactorDisableSheetState extends ConsumerState<TwoFactorDisableSheet> {
  final _password = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _disable() async {
    if (_password.text.isEmpty) throw const ActionCancelled();
    await ref.read(authRepositoryProvider).disableTwoFactor(_password.text);
    await ref.read(sessionProvider.notifier).refresh();
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Turn off two-step sign-in?', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        const Text('Signing in will need only your password again.'),
        const SizedBox(height: 16),
        TextField(
          controller: _password,
          obscureText: true,
          autofocus: true,
          autofillHints: const [AutofillHints.password],
          decoration: const InputDecoration(labelText: 'Your password'),
        ),
        const SizedBox(height: 16),
        AppButton(label: 'Turn off', icon: Icons.no_encryption_outlined, expand: true, onPressed: _disable),
      ],
    ),
  );
}
