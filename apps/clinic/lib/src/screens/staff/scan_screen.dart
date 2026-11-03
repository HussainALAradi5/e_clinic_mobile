import 'dart:async';

import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../widgets/staff/scan/camera_unavailable.dart';
import '../../widgets/staff/scan/scan_frame.dart';
import '../../widgets/staff/scan/scan_overlay.dart';
import '../../widgets/staff/scan/scan_result_sheet.dart';
import '../../widgets/staff/scan/type_code_dialog.dart';

/// `/scan` — full-screen camera for the clinic's signed codes: patient cards, check-in codes from the patient app,
/// orders, prescriptions, invoices. The result opens in a sheet (check the patient in, open the record).
/// The camera runs only while this tab is on screen and the app is in front.
class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  final _camera = MobileScannerController(detectionSpeed: DetectionSpeed.noDuplicates, autoStart: false);
  late final AppLifecycleListener _lifecycle;
  var _onScreen = false;
  var _inFront = true;
  var _busy = false;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onHide: () {
        _inFront = false;
        _syncCamera();
      },
      onShow: () {
        _inFront = true;
        _syncCamera();
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Tabs off screen have their tickers muted by the shell.
    final onScreen = TickerMode.valuesOf(context).enabled;
    if (onScreen != _onScreen) {
      _onScreen = onScreen;
      _syncCamera();
    }
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    unawaited(_camera.dispose());
    super.dispose();
  }

  void _syncCamera() {
    final run = _onScreen && _inFront && !_busy;
    // Starting a running camera (or stopping a stopped one) is harmless; a missing camera shows in the view.
    unawaited((run ? _camera.start() : _camera.stop()).catchError((Object _) {}));
  }

  void _onDetect(BarcodeCapture capture) {
    final payload = capture.barcodes.map((b) => b.rawValue).whereType<String>().firstOrNull;
    if (payload != null && !_busy) unawaited(_resolve(payload));
  }

  Future<void> _resolve(String payload) async {
    setState(() => _busy = true);
    _syncCamera();
    try {
      final result = await ref.read(codeRepositoryProvider).scan(payload);
      unawaited(HapticFeedback.mediumImpact());
      if (mounted) await showScanResultSheet(context, result);
    } catch (error) {
      unawaited(HapticFeedback.heavyImpact());
      if (mounted) AppSnack.error(context, error);
    } finally {
      if (mounted) {
        setState(() => _busy = false);
        _syncCamera();
      }
    }
  }

  Future<void> _typeCode() async {
    final payload = await showDialog<String>(context: context, builder: (_) => const TypeCodeDialog());
    if (payload != null && payload.trim().isNotEmpty) await _resolve(payload);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _camera,
            onDetect: _onDetect,
            errorBuilder: (context, error) => CameraUnavailable(
              denied: error.errorCode == MobileScannerErrorCode.permissionDenied,
              onTypeCode: _typeCode,
            ),
          ),
          ScanFrame(camera: _camera),
          ScanOverlay(
            onTorch: () => unawaited(_camera.toggleTorch().catchError((Object _) {})),
            onTypeCode: _busy ? null : _typeCode,
          ),
          if (_busy)
            const ColoredBox(
              color: Color(0x88000000),
              child: Center(child: CircularProgressIndicator(color: Colors.white)),
            ),
        ],
      ),
    );
  }
}
