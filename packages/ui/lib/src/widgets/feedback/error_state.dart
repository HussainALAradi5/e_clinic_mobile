import 'package:e_clinic_core/core.dart';
import 'package:flutter/material.dart';

import 'empty_state.dart';

/// What went wrong and a way to try again (offline gets its own wording).
class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.error, this.onRetry});

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final api = error is ApiException ? error as ApiException : null;
    final offline = api?.isOffline ?? false;
    return EmptyState(
      icon: offline ? Icons.wifi_off_rounded : Icons.cloud_off_rounded,
      title: offline ? 'You are offline' : 'Could not load this',
      message: api?.message ?? 'Something went wrong. Please try again.',
      action: onRetry == null
          ? null
          : OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
    );
  }
}
