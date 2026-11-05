part of 'signature_screen.dart';

/// The signature on file (or "none"), with Remove.
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
