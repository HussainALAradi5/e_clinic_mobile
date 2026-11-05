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
        label: UiText.newPassword,
        autofillHints: const [AutofillHints.newPassword],
        validator: (v) => PasswordRules.valid(v ?? '') ? null : UiText.passwordWeak,
      ),
      const SizedBox(height: 10),
      PasswordChecklist(controller: password),
      const SizedBox(height: 16),
      PasswordField(
        controller: confirm,
        label: UiText.repeatTheNewPassword,
        textInputAction: TextInputAction.done,
        autofillHints: const [AutofillHints.newPassword],
        validator: (v) => v == password.text ? null : UiText.passwordsDiffer,
      ),
    ],
  );
}
