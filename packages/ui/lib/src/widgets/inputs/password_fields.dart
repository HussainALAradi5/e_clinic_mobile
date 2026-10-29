import 'package:flutter/material.dart';

/// The server's password rules (the breached-password check runs on the server only).
abstract final class PasswordRules {
  static const minLength = 10;

  static List<({String label, bool ok})> check(String value) => [
    (label: '$minLength+ characters', ok: value.length >= minLength),
    (label: 'Upper and lower case', ok: RegExp('[a-z]').hasMatch(value) && RegExp('[A-Z]').hasMatch(value)),
    (label: 'A number', ok: RegExp(r'\d').hasMatch(value)),
    (label: 'A symbol', ok: RegExp('[^A-Za-z0-9]').hasMatch(value)),
  ];

  static bool valid(String value) => check(value).every((c) => c.ok);
}

/// Password input with a show / hide toggle.
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    this.label = 'Password',
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.autofillHints = const [AutofillHints.password],
    this.errorText,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String? value)? validator;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String> autofillHints;
  final String? errorText;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  var _hidden = true;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: widget.controller,
    obscureText: _hidden,
    autocorrect: false,
    enableSuggestions: false,
    textInputAction: widget.textInputAction,
    autofillHints: widget.autofillHints,
    validator: widget.validator,
    onFieldSubmitted: widget.onSubmitted,
    decoration: InputDecoration(
      labelText: widget.label,
      errorText: widget.errorText,
      prefixIcon: const Icon(Icons.lock_outline_rounded),
      suffixIcon: IconButton(
        tooltip: _hidden ? 'Show password' : 'Hide password',
        icon: Icon(_hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined),
        onPressed: () => setState(() => _hidden = !_hidden),
      ),
    ),
  );
}

/// Live checklist of the password rules under a new-password field.
class PasswordChecklist extends StatelessWidget {
  const PasswordChecklist({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: controller,
    builder: (context, value, _) {
      final scheme = Theme.of(context).colorScheme;
      return Wrap(
        spacing: 12,
        runSpacing: 6,
        children: [
          for (final rule in PasswordRules.check(value.text))
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  rule.ok ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  size: 16,
                  color: rule.ok ? scheme.primary : scheme.outline,
                ),
                const SizedBox(width: 4),
                Text(rule.label, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
        ],
      );
    },
  );
}

/// New password with the live rule checklist, then the repeat — the same block for a reset and a change.
class NewPasswordFields extends StatelessWidget {
  const NewPasswordFields({super.key, required this.password, required this.confirm});

  final TextEditingController password;
  final TextEditingController confirm;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      PasswordField(
        controller: password,
        label: 'New password',
        autofillHints: const [AutofillHints.newPassword],
        validator: (v) => PasswordRules.valid(v ?? '') ? null : 'The password does not meet every rule yet.',
      ),
      const SizedBox(height: 10),
      PasswordChecklist(controller: password),
      const SizedBox(height: 16),
      PasswordField(
        controller: confirm,
        label: 'Repeat the new password',
        textInputAction: TextInputAction.done,
        autofillHints: const [AutofillHints.newPassword],
        validator: (v) => v == password.text ? null : 'The two passwords are not the same.',
      ),
    ],
  );
}
