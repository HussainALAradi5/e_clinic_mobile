part of 'account_security_screen.dart';

/// Two-step sign-in: on / off with its sheet; roles that must keep it cannot turn it off.
class _TwoFactorTile extends StatelessWidget {
  const _TwoFactorTile({required this.state});

  final TwoFactorState state;

  Future<void> _open(BuildContext context, Widget sheet, String done) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => sheet,
    );
    if ((changed ?? false) && context.mounted) AppSnack.success(context, done);
  }

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(state.enabled ? Icons.verified_user_rounded : Icons.shield_outlined),
    title: const Text('Two-step sign-in'),
    subtitle: Text(switch ((state.enabled, state.mandatory)) {
      (true, true) => 'On — your role requires it.',
      (true, false) => 'On — a code from your authenticator app at sign-in.',
      (false, true) => 'Your role requires it: turn it on now.',
      (false, false) => 'Off — add a code from an authenticator app at sign-in.',
    }),
    trailing: state.enabled && state.mandatory ? null : const Icon(Icons.chevron_right_rounded),
    onTap: switch ((state.enabled, state.mandatory)) {
      (true, true) => null,
      (true, false) => () => _open(context, const TwoFactorDisableSheet(), 'Two-step sign-in is off.'),
      _ => () => _open(context, const TwoFactorSetupSheet(), 'Two-step sign-in is on.'),
    },
  );
}
