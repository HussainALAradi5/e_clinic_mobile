import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// The target frame in the middle of the camera view, while the camera works.
class ScanFrame extends StatelessWidget {
  const ScanFrame({super.key, required this.camera});

  final MobileScannerController camera;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: camera,
      builder: (_, state, _) => state.error != null
          ? const SizedBox.shrink()
          : Center(
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 3),
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
            ),
    );
  }
}
