import 'dart:async';

import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../widgets/scan_result_sheet.dart';

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
    final payload = await showDialog<String>(context: context, builder: (_) => const _TypeCodeDialog());
    if (payload != null && payload.trim().isNotEmpty) await _resolve(payload);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _camera,
            onDetect: _onDetect,
            errorBuilder: (context, error) => _CameraUnavailable(
              denied: error.errorCode == MobileScannerErrorCode.permissionDenied,
              onTypeCode: _typeCode,
            ),
          ),
          // Target frame, while the camera works.
          ValueListenableBuilder(
            valueListenable: _camera,
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
          ),
          SafeArea(
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
                        onPressed: () => unawaited(_camera.toggleTorch().catchError((Object _) {})),
                        icon: const Icon(Icons.flashlight_on_outlined),
                      ),
                      IconButton(
                        tooltip: 'Type the code',
                        color: Colors.white,
                        onPressed: _busy ? null : _typeCode,
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

/// No camera, or no permission: say how to fix it and offer typing the code instead.
class _CameraUnavailable extends StatelessWidget {
  const _CameraUnavailable({required this.denied, required this.onTypeCode});

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
                denied ? 'Camera access is off' : 'The camera is not available',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                denied
                    ? 'Allow e-Clinic Staff to use the camera in your phone settings, or type the code instead.'
                    : 'You can still type the code printed under the QR code.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onTypeCode,
                icon: const Icon(Icons.keyboard_outlined),
                label: const Text('Type the code'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// For a code that will not scan (damaged label, emulator without a camera): the text printed under it.
class _TypeCodeDialog extends StatefulWidget {
  const _TypeCodeDialog();

  @override
  State<_TypeCodeDialog> createState() => _TypeCodeDialogState();
}

class _TypeCodeDialogState extends State<_TypeCodeDialog> {
  final _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Type the code'),
    content: TextField(
      controller: _code,
      autofocus: true,
      autocorrect: false,
      decoration: const InputDecoration(labelText: 'Code', hintText: 'appointment:APT-…'),
      onSubmitted: (value) => Navigator.of(context).pop(value),
    ),
    actions: [
      TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
      FilledButton(onPressed: () => Navigator.of(context).pop(_code.text), child: const Text('Look up')),
    ],
  );
}
