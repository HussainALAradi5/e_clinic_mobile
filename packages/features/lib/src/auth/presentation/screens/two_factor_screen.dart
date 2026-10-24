import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/session_controller.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/code_field.dart';

/// `/login/2fa` — the 6-digit code from the authenticator app, or a one-time recovery code.
class TwoFactorScreen extends ConsumerStatefulWidget {
  const TwoFactorScreen({super.key, required this.challenge});

  final TwoFactorChallenge challenge;

  @override
  ConsumerState<TwoFactorScreen> createState() => _TwoFactorScreenState();
}

class _TwoFactorScreenState extends ConsumerState<TwoFactorScreen> {
  final _code = TextEditingController();
  var _recovery = false;
  var _busy = false;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final code = _code.text.trim();
    if (_busy || code.length < (_recovery ? 8 : 6)) throw const ActionCancelled();
    _busy = true;
    try {
      await ref
          .read(sessionProvider.notifier)
          .verifyTwoFactor(widget.challenge, code, isRecoveryCode: _recovery);
    } catch (_) {
      _code.clear();
      rethrow;
    } finally {
      _busy = false;
    }
  }

  @override
  Widget build(BuildContext context) => AuthScaffold(
    title: 'Two-step check',
    subtitle: _recovery
        ? 'Enter one of the recovery codes you saved when you set up two-step sign-in.'
        : 'Enter the 6-digit code from your authenticator app for ${widget.challenge.email}.',
    onBack: () => Navigator.of(context).maybePop(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_recovery)
          TextField(
            controller: _code,
            autofocus: true,
            autocorrect: false,
            decoration: const InputDecoration(labelText: 'Recovery code', prefixIcon: Icon(Icons.key_rounded)),
          )
        else
          CodeField(
            controller: _code,
            onCompleted: (_) async {
              try {
                await _verify();
              } catch (error) {
                if (context.mounted && error is! ActionCancelled) AppSnack.error(context, error);
              }
            },
          ),
        const SizedBox(height: 24),
        AppButton(label: 'Verify', icon: Icons.verified_user_outlined, expand: true, onPressed: _verify),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => setState(() {
            _recovery = !_recovery;
            _code.clear();
          }),
          child: Text(_recovery ? 'Use the authenticator code' : 'Use a recovery code instead'),
        ),
      ],
    ),
  );
}
