import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/settings/settings_text.dart';
import '../../controllers/settings/theme_mode_controller.dart';

/// Appearance switch for the account pages: follow the phone, or always light / dark.
class ThemeModeTile extends ConsumerWidget {
  const ThemeModeTile({super.key});

  static const _modes = [
    (ThemeMode.system, SettingsText.themePhone, Icons.brightness_auto_rounded),
    (ThemeMode.light, SettingsText.themeLight, Icons.light_mode_rounded),
    (ThemeMode.dark, SettingsText.themeDark, Icons.dark_mode_rounded),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(SettingsText.appearance, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<ThemeMode>(
                showSelectedIcon: false,
                segments: [
                  for (final (value, label, icon) in _modes)
                    ButtonSegment(value: value, label: Text(label), icon: Icon(icon)),
                ],
                selected: {mode},
                onSelectionChanged: (s) => ref.read(themeModeProvider.notifier).set(s.first),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
