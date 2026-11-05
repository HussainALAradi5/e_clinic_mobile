import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_shell/shell.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/staff/chat_text.dart';

/// My Online / Offline status in chat as a chip that switches it. Signing in sets Online and signing out
/// everywhere Offline on the server; this changes it in between.
class PresenceSwitch extends ConsumerStatefulWidget {
  const PresenceSwitch({super.key});

  @override
  ConsumerState<PresenceSwitch> createState() => _PresenceSwitchState();
}

class _PresenceSwitchState extends ConsumerState<PresenceSwitch> {
  var _busy = false;

  Future<void> _toggle(bool online) async {
    setState(() => _busy = true);
    try {
      await ref.read(authRepositoryProvider).setPresence(online ? 'offline' : 'online');
      await ref.read(sessionProvider.notifier).refresh();
    } catch (e) {
      if (mounted) AppSnack.error(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final online = ref.watch(currentUserProvider)?.online ?? false;
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: online ? ChatText.goOffline : ChatText.goOnline,
      child: ActionChip(
        onPressed: _busy ? null : () => _toggle(online),
        avatar: Icon(Icons.circle, size: 10, color: online ? Colors.green.shade500 : scheme.outline),
        label: Text(online ? ChatText.online : ChatText.offline),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
