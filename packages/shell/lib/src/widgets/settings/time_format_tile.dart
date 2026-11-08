import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/settings/settings_text.dart';
import '../../controllers/auth/session_controller.dart';

/// Profile choice for the account pages: read times on the 12-hour (default) or the 24-hour clock.
class TimeFormatTile extends ConsumerWidget {
  const TimeFormatTile({super.key});

  static const _twelveHour = '12h';
  static const _twentyFourHour = '24h';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final format = ref.watch(currentUserProvider)?.timeFormat ?? _twelveHour;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(SettingsText.timeFormat, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<String>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: _twelveHour, label: Text(SettingsText.twelveHour)),
                  ButtonSegment(value: _twentyFourHour, label: Text(SettingsText.twentyFourHour)),
                ],
                selected: {format},
                onSelectionChanged: (s) => ref.read(sessionProvider.notifier).setTimeFormat(s.first),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
