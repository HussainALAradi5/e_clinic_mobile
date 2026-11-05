import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../constants/common/common_text.dart';
import '../../../constants/staff/pharmacy_text.dart';
import '../scan/camera_unavailable.dart';
import '../scan/type_code_dialog.dart';

/// Scans the barcode on a medicine pack and returns it (null when closed); the code can be typed instead.
Future<String?> scanPack(BuildContext context) => showModalBottomSheet<String>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  backgroundColor: Colors.black,
  builder: (_) => const FractionallySizedBox(heightFactor: 0.75, child: _PackScanner()),
);

class _PackScanner extends StatefulWidget {
  const _PackScanner();

  @override
  State<_PackScanner> createState() => _PackScannerState();
}

class _PackScannerState extends State<_PackScanner> {
  final _camera = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.ean13, BarcodeFormat.ean8, BarcodeFormat.dataMatrix, BarcodeFormat.code128],
  );
  var _done = false;

  @override
  void dispose() {
    unawaited(_camera.dispose());
    super.dispose();
  }

  void _finish(String? code) {
    if (_done || code == null || code.trim().isEmpty) return;
    _done = true;
    Navigator.pop(context, code.trim());
  }

  Future<void> _typeCode() async => _finish(
    await showDialog<String>(
      context: context,
      builder: (_) => const TypeCodeDialog(label: PharmacyText.barcodeNumber, hint: PharmacyText.barcodeHint),
    ),
  );

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      MobileScanner(
        controller: _camera,
        onDetect: (capture) => _finish(capture.barcodes.firstOrNull?.rawValue),
        errorBuilder: (context, error) => CameraUnavailable(
          denied: error.errorCode == MobileScannerErrorCode.permissionDenied,
          onTypeCode: _typeCode,
        ),
      ),
      Center(
        child: Container(
          width: 280,
          height: 140,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 3),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      Positioned(
        left: 16,
        right: 16,
        bottom: 16,
        child: Row(
          children: [
            const Expanded(
              child: Text(PharmacyText.pointAtBarcode, style: TextStyle(color: Colors.white)),
            ),
            TextButton(onPressed: _typeCode, child: const Text(PharmacyText.typeIt)),
            IconButton(
              tooltip: CommonText.close,
              color: Colors.white,
              icon: const Icon(Icons.close_rounded),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    ],
  );
}
