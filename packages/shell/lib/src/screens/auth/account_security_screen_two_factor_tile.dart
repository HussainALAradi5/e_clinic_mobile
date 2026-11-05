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
    title: const Text(AuthText.twoFactor),
    subtitle: Text(switch ((state.enabled, state.mandatory)) {
      (true, true) => AuthText.twoFactorOnRequired,
      (true, false) => AuthText.twoFactorOn,
      (false, true) => AuthText.twoFactorRequired,
      (false, false) => AuthText.twoFactorOff,
    }),
    trailing: state.enabled && state.mandatory ? null : const Icon(Icons.chevron_right_rounded),
    onTap: switch ((state.enabled, state.mandatory)) {
      (true, true) => null,
      (true, false) => () => _open(context, const TwoFactorDisableSheet(), AuthText.twoFactorTurnedOff),
      _ => () => _open(context, const TwoFactorSetupSheet(), AuthText.twoFactorTurnedOn),
    },
  );
}
