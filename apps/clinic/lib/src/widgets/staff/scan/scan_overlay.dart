import 'package:flutter/material.dart';

import '../../../constants/staff/scan_text.dart';

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
                  child: Text(ScanText.scanACode, style: theme.textTheme.titleLarge?.copyWith(color: Colors.white)),
                ),
                IconButton(
                  tooltip: ScanText.torch,
                  color: Colors.white,
                  onPressed: onTorch,
                  icon: const Icon(Icons.flashlight_on_outlined),
                ),
                IconButton(
                  tooltip: ScanText.typeCode,
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
              ScanText.scanHint,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}
