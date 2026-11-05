import 'package:flutter/material.dart';

import '../../../constants/staff/scan_text.dart';

/// No camera, or no permission: say how to fix it and offer typing the code instead.
class CameraUnavailable extends StatelessWidget {
  const CameraUnavailable({super.key, required this.denied, required this.onTypeCode});

  final bool denied;
  final VoidCallback onTypeCode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.no_photography_outlined, size: 48, color: Colors.white70),
              const SizedBox(height: 16),
              Text(
                denied ? ScanText.cameraOff : ScanText.cameraUnavailable,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                denied ? ScanText.cameraOffHint : ScanText.cameraUnavailableHint,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onTypeCode,
                icon: const Icon(Icons.keyboard_outlined),
                label: const Text(ScanText.typeCode),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
