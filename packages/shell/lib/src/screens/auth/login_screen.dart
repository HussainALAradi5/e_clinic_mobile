import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/routes/auth_paths.dart';
import '../../controllers/auth/session_controller.dart';
import '../../widgets/auth/auth_scaffold.dart';

/// `/login` — email and password; hands over to the two-factor screen when the account needs a code.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  var _submitting = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_form.currentState?.validate() ?? false)) throw const ActionCancelled();
    final challenge = await ref.read(sessionProvider.notifier).login(_email.text, _password.text);
    if (challenge != null && mounted) {
      await context.push(AuthPaths.twoFactor, extra: challenge);
    }
    // Signed in: the router leaves this screen by itself.
  }

  /// Done / Enter on the password signs in too (the button shows its own progress and errors; this path the snack).
  Future<void> _submitFromKeyboard() async {
    if (_submitting) return;
    _submitting = true;
    try {
      await _submit();
    } on ActionCancelled {
      // The form shows what is missing.
    } catch (error) {
      if (mounted) AppSnack.error(context, error);
    } finally {
      _submitting = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AuthScaffold(
      title: 'Welcome back',
      subtitle: 'Your visits and results — or your day at the clinic.',
      child: AutofillGroup(
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email, AutofillHints.username],
                autocorrect: false,
                decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.mail_outline_rounded)),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) return 'Enter your email.';
                  if (!text.contains('@') || !text.contains('.')) return 'Enter a valid email address.';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              PasswordField(
                controller: _password,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submitFromKeyboard(),
                validator: (value) => (value ?? '').isEmpty ? 'Enter your password.' : null,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push(AuthPaths.forgotPassword, extra: _email.text.trim()),
                  child: const Text('Forgot password?'),
                ),
              ),
              const SizedBox(height: 8),
              AppButton(label: 'Sign in', icon: Icons.login_rounded, expand: true, onPressed: _submit),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Text(
                  'Patients: new here? Ask the front desk for your invitation — it sets up your account.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
