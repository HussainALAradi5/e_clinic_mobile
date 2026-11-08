import 'package:e_clinic_core/core.dart';
import 'package:flutter/material.dart';

import '../../constants/ui_text.dart';

/// Says the page shows the phone's saved copy because there is no connection, and since when.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, required this.savedAt, this.onRetry});

  final DateTime savedAt;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final time = ClinicClock.local(savedAt);
    final savedTime = ClinicClock.clock(time.hour, time.minute);
    return Material(
      color: scheme.tertiaryContainer,
      borderRadius: BorderRadius.circular(16),
      child: ListTile(
        leading: Icon(Icons.cloud_off_rounded, color: scheme.onTertiaryContainer),
        title: Text(UiText.offline, style: TextStyle(color: scheme.onTertiaryContainer)),
        subtitle: Text(UiText.offlineCopy(savedTime), style: TextStyle(color: scheme.onTertiaryContainer)),
        trailing: onRetry == null
            ? null
            : IconButton(
                tooltip: UiText.tryAgain,
                color: scheme.onTertiaryContainer,
                icon: const Icon(Icons.refresh_rounded),
                onPressed: onRetry,
              ),
      ),
    );
  }
}
