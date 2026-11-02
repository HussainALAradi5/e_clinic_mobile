part of 'password_fields.dart';

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
