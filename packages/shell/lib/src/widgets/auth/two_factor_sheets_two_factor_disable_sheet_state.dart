part of 'two_factor_sheets.dart';

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
