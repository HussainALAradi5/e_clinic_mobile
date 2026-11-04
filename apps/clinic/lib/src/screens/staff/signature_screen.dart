import 'dart:typed_data';

import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/staff/signature_text.dart';
import '../../widgets/common/attach_photo_button.dart';
import '../../widgets/staff/settings/signature_pad.dart';

/// `/account/signature` (staff) — sign on the screen or upload a photo of the signature; it prints on every document
/// the staff member issues. Shows the current one, which can be removed.
class SignatureScreen extends ConsumerStatefulWidget {
  const SignatureScreen({super.key});

  @override
  ConsumerState<SignatureScreen> createState() => _SignatureScreenState();
}

class _SignatureScreenState extends ConsumerState<SignatureScreen> {
  final _pad = SignaturePadController();
  late Future<Uint8List?> _current = ref.read(signatureRepositoryProvider).current();
  var _busy = false;

  @override
  void dispose() {
    _pad.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action, String done) async {
    setState(() => _busy = true);
    try {
      await action();
      if (!mounted) return;
      AppSnack.success(context, done);
      setState(() => _current = ref.read(signatureRepositoryProvider).current());
    } catch (error) {
      if (mounted) AppSnack.error(context, error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _saveDrawing() async {
    final png = await _pad.toPng(MediaQuery.devicePixelRatioOf(context));
    if (png == null) {
      if (mounted) AppSnack.info(context, SignatureText.empty);
      return;
    }
    await _run(() => ref.read(signatureRepositoryProvider).save(png, 'signature.png'), SignatureText.saved);
    _pad.clear();
  }

  Future<void> _upload() async {
    final photo = await pickPhoto(context);
    if (photo == null || !mounted) return;
    final bytes = await photo.readAsBytes();
    if (!mounted) return;
    if (bytes.length > SignatureText.maxBytes) {
      AppSnack.info(context, SignatureText.tooBig);
      return;
    }
    await _run(() => ref.read(signatureRepositoryProvider).save(bytes, photo.name), SignatureText.saved);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    return Scaffold(
      appBar: AppBar(title: const Text(SignatureText.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text(SignatureText.intro, style: muted),
          const SizedBox(height: 16),
          FutureBuilder<Uint8List?>(
            future: _current,
            builder: (context, snap) => _CurrentSignature(
              image: snap.data,
              loading: snap.connectionState != ConnectionState.done,
              onRemove: _busy ? null : () => _run(ref.read(signatureRepositoryProvider).remove, SignatureText.removed),
            ),
          ),
          const SizedBox(height: 20),
          Text(SignatureText.draw, style: muted),
          const SizedBox(height: 8),
          SizedBox(
            height: 180,
            child: SignaturePad(controller: _pad, label: SignatureText.pad),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton.icon(
                onPressed: _pad.clear,
                icon: const Icon(Icons.cleaning_services_outlined),
                label: const Text(SignatureText.clear),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: _busy ? null : _saveDrawing,
                icon: const Icon(Icons.save_rounded),
                label: const Text(SignatureText.save),
              ),
            ],
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _busy ? null : _upload,
            icon: const Icon(Icons.photo_camera_outlined),
            label: const Text(SignatureText.upload),
          ),
        ],
      ),
    );
  }
}

class _CurrentSignature extends StatelessWidget {
  const _CurrentSignature({required this.image, required this.loading, required this.onRemove});

  final Uint8List? image;
  final bool loading;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final picture = image;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              height: 72,
              width: 200,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: loading
                  ? const CircularProgressIndicator()
                  : picture == null
                  ? const Text(SignatureText.none, style: TextStyle(color: Colors.black54))
                  : Image.memory(picture, fit: BoxFit.contain, semanticLabel: SignatureText.current),
            ),
            const Spacer(),
            if (picture != null) TextButton(onPressed: onRemove, child: const Text(SignatureText.remove)),
          ],
        ),
      ),
    );
  }
}
