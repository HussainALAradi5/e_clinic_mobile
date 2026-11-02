part of 'account_security_screen.dart';

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
