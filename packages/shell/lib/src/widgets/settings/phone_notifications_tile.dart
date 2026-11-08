import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/settings/settings_text.dart';
import '../../controllers/settings/phone_notifications_controller.dart';

/// "Notifications" switch for the account pages. Off stops them on every device of the person; the
/// inbox keeps every message either way.
class PhoneNotificationsTile extends ConsumerWidget {
  const PhoneNotificationsTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(phoneNotificationsProvider);
    final on = value.value ?? false;
    return Card(
      child: AppSwitchTile(
        secondary: const Icon(Icons.notifications_active_outlined),
        title: const Text(SettingsText.notifications),
        subtitle: const Text(SettingsText.notificationsHint),
        value: on,
        onChanged: value.isLoading || value.value == null
            ? null
            : (next) async {
                try {
                  final allowed = await ref.read(phoneNotificationsProvider.notifier).set(next);
                  if (!context.mounted) return;
                  if (!allowed) {
                    AppSnack.info(
                      context,
                      SettingsText.notificationsBlocked,
                    );
                  } else {
                    AppSnack.success(context, next ? SettingsText.notificationsOn : SettingsText.notificationsOff);
                  }
                } catch (e) {
                  if (context.mounted) AppSnack.error(context, e);
                }
              },
      ),
    );
  }
}
