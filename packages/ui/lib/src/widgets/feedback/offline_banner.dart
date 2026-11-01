import 'package:e_clinic_core/core.dart';
import 'package:flutter/material.dart';

/// Says the page shows the phone's saved copy because there is no connection, and since when.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, required this.savedAt, this.onRetry});

  final DateTime savedAt;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final time = ClinicClock.local(savedAt);
    final hhmm = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    return Material(
      color: scheme.tertiaryContainer,
      borderRadius: BorderRadius.circular(16),
      child: ListTile(
        leading: Icon(Icons.cloud_off_rounded, color: scheme.onTertiaryContainer),
        title: Text('Offline', style: TextStyle(color: scheme.onTertiaryContainer)),
        subtitle: Text(
          'Showing the copy from $hhmm. Actions come back with the connection.',
          style: TextStyle(color: scheme.onTertiaryContainer),
        ),
        trailing: onRetry == null
            ? null
            : IconButton(
                tooltip: 'Try again',
                color: scheme.onTertiaryContainer,
                icon: const Icon(Icons.refresh_rounded),
                onPressed: onRetry,
              ),
      ),
    );
  }
}
