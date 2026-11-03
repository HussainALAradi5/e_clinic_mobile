import 'package:flutter/material.dart';

/// Over the camera: the title with Torch and "Type the code" at the top, what can be scanned at the bottom.
class ScanOverlay extends StatelessWidget {
  const ScanOverlay({super.key, required this.onTorch, required this.onTypeCode});

  final VoidCallback onTorch;

  /// Null while a code is being checked.
  final VoidCallback? onTypeCode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text('Scan a code', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white)),
                ),
                IconButton(
                  tooltip: 'Torch',
                  color: Colors.white,
                  onPressed: onTorch,
                  icon: const Icon(Icons.flashlight_on_outlined),
                ),
                IconButton(
                  tooltip: 'Type the code',
                  color: Colors.white,
                  onPressed: onTypeCode,
                  icon: const Icon(Icons.keyboard_outlined),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
            child: Text(
              'Patient card, check-in code from the patient app, order label, prescription or invoice.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}
