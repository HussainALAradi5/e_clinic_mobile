import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/auth/auth_text.dart';
import '../../controllers/auth/session_controller.dart';
import 'code_field.dart';

part 'two_factor_sheets_two_factor_disable_sheet.dart';
part 'two_factor_sheets_two_factor_disable_sheet_state.dart';

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
      AppSnack.info(context, AuthText.noAuthenticator);
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
                Text(AuthText.twoFactorIsOn, style: text.titleLarge),
                const SizedBox(height: 8),
                const InfoNote(
                  icon: Icons.key_rounded,
                  text: AuthText.keepCodes,
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
                  onPressed: () => _copy(codes.join('\n'), AuthText.recoveryCodes),
                  icon: const Icon(Icons.copy_rounded),
                  label: const Text(AuthText.copyCodes),
                ),
                const SizedBox(height: 8),
                FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text(AuthText.done)),
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
                    Text(AuthText.turnOnTitle, style: text.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      '1. Add e-Clinic to an authenticator app (Google Authenticator, Microsoft Authenticator …).',
                      style: text.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    FilledButton.tonalIcon(
                      onPressed: () => _openAuthenticator(link),
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: const Text(AuthText.openAuthenticator),
                    ),
                    if (secret != null)
                      TextButton.icon(
                        onPressed: () => _copy(secret, AuthText.key),
                        icon: const Icon(Icons.copy_rounded),
                        label: Text(AuthText.copyKey(secret), overflow: TextOverflow.ellipsis),
                      ),
                    const SizedBox(height: 12),
                    Text('2. Type the 6-digit code the app shows.', style: text.bodyMedium),
                    const SizedBox(height: 8),
                    CodeField(controller: _code),
                    const SizedBox(height: 16),
                    AppButton(label: AuthText.turnOn, icon: Icons.verified_user_rounded, expand: true, onPressed: _confirm),
                  ],
                );
              },
            ),
    );
  }
}
