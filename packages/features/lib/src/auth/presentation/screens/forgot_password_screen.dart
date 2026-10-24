import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth_paths.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/code_field.dart';

enum _Step { email, code, password }

/// `/password/forgot` — email → 6-digit code from the email → new password. Also completes a portal invitation.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key, this.email});

  final String? email;

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _form = GlobalKey<FormState>();
  late final _email = TextEditingController(text: widget.email);
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  var _step = _Step.email;
  String? _token;

  AuthRepository get _auth => ref.read(authRepositoryProvider);

  @override
  void dispose() {
    for (final c in [_email, _code, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _send() async {
    if (!(_form.currentState?.validate() ?? false)) throw const ActionCancelled();
    await _auth.forgotPassword(_email.text.trim());
    if (mounted) setState(() => _step = _Step.code);
  }

  Future<void> _verify() async {
    if (_code.text.length != 6) throw const ActionCancelled();
    try {
      _token = await _auth.verifyResetCode(email: _email.text.trim(), code: _code.text);
    } on ApiException {
      _code.clear();
      rethrow;
    }
    if (mounted) setState(() => _step = _Step.password);
  }

  Future<void> _reset() async {
    if (!(_form.currentState?.validate() ?? false)) throw const ActionCancelled();
    await _auth.resetPassword(
      token: _token!,
      email: _email.text.trim(),
      password: _password.text,
      passwordConfirmation: _confirm.text,
    );
    if (!mounted) return;
    AppSnack.success(context, 'Your password is set. Sign in with it now.');
    context.go(AuthPaths.login);
  }

  @override
  Widget build(BuildContext context) {
    final (title, subtitle) = switch (_step) {
      _Step.email => ('Reset your password', 'We will email you a 6-digit code. It also works for a new portal invitation.'),
      _Step.code => ('Check your email', 'Enter the 6-digit code we sent to ${_email.text.trim()}.'),
      _Step.password => ('Choose a new password', 'Use it from now on to sign in on the app and the website.'),
    };
    return AuthScaffold(
      title: title,
      subtitle: subtitle,
      onBack: () => _step == _Step.email
          ? context.pop()
          : setState(() => _step = _step == _Step.password ? _Step.code : _Step.email),
      child: Form(
        key: _form,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: KeyedSubtree(
            key: ValueKey(_step),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: switch (_step) {
                _Step.email => [
                  TextFormField(
                    controller: _email,
                    autofocus: widget.email == null || widget.email!.isEmpty,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.mail_outline_rounded),
                    ),
                    validator: (v) => (v ?? '').trim().contains('@') ? null : 'Enter the email you sign in with.',
                  ),
                  const SizedBox(height: 24),
                  AppButton(label: 'Send code', icon: Icons.send_rounded, expand: true, onPressed: _send),
                ],
                _Step.code => [
                  CodeField(controller: _code),
                  const SizedBox(height: 24),
                  AppButton(label: 'Continue', expand: true, onPressed: _verify),
                  const SizedBox(height: 8),
                  AppButton(
                    label: 'Send a new code',
                    variant: ButtonVariant.text,
                    onPressed: () async {
                      await _auth.forgotPassword(_email.text.trim());
                      if (context.mounted) AppSnack.info(context, 'A new code is on its way.');
                    },
                  ),
                ],
                _Step.password => [
                  PasswordField(
                    controller: _password,
                    label: 'New password',
                    autofillHints: const [AutofillHints.newPassword],
                    validator: (v) => PasswordRules.valid(v ?? '') ? null : 'The password does not meet every rule yet.',
                  ),
                  const SizedBox(height: 10),
                  PasswordChecklist(controller: _password),
                  const SizedBox(height: 16),
                  PasswordField(
                    controller: _confirm,
                    label: 'Repeat the new password',
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.newPassword],
                    validator: (v) => v == _password.text ? null : 'The two passwords are not the same.',
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: 'Save password',
                    icon: Icons.check_rounded,
                    lock: ButtonLock.once,
                    expand: true,
                    onPressed: _reset,
                  ),
                ],
              },
            ),
          ),
        ),
      ),
    );
  }
}
